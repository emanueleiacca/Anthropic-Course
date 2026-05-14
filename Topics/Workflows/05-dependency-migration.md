---
title: Playbook - Migration / dependency upgrade
tags: [migration, dependency, upgrade, codemod, breaking-changes, .NET, npm]
last_updated: 2026-05-14
audience: llm-advisory
---

# Migration / dependency upgrade

### Playbook: Safe layered dependency upgrade

**TL;DR**: Workflow incrementale per upgrade di dipendenze in modo che ogni failure sia attribuibile. Ordine: toolchain → core/shared libs → feature libs → app code. Test dopo ogni step. Codemod automatici per breaking changes. Pattern usato da Stripe per migrazioni multi-package.

**Contesti applicabili**: Tutti

**Pre-requisiti**:
- Lockfile committed e baseline `main` verde
- Test suite affidabile (>70% coverage critical path)
- Branch dedicato `chore/upgrade-X-to-Y`

**Workflow step-by-step**:

1. **Baseline prep**:
   - `git status` deve essere clean
   - `pnpm test && pnpm build && pnpm lint` tutti pass
   - Tag baseline: `git tag pre-upgrade-$(date +%Y%m%d)`

2. **Exploration phase** (Plan Mode):
   - Claude legge `package.json`, `pyproject.toml`, `Cargo.toml`
   - Confronta con latest stable di ogni dep (via Context7 MCP o `npm outdated`)
   - Identifica BREAKING changes leggendo CHANGELOG/release notes
   - Output: `upgrade-plan.md` con tier:
     - **Tier 0 Toolchain**: Node, Python, Rust, build tool (vite, tsc)
     - **Tier 1 Shared/core**: framework (Next, Django, axum)
     - **Tier 2 Feature libs**: usabili in isolamento (date-fns, lodash)
     - **Tier 3 App code**: tutto cio che dipende dai sopra

3. **Tier 0 - Toolchain first**:
   - Upgrade Node/Python/Rust version (`.nvmrc`, `pyproject.toml`, `rust-toolchain`)
   - Verify: `node -v && pnpm install && pnpm test`
   - Commit isolato

4. **Tier 1 - Core/shared one-at-a-time**:
   - `pnpm add framework@latest`
   - Claude legge release notes via Context7 MCP
   - Applica codemod ufficiali se disponibili (`npx @next/codemod@latest`)
   - Run test, fix breaks, commit per dep

5. **Tier 2 - Feature libs batch (fan-out se molti)**:
   - Sub-agent per dep, ognuno: upgrade + test isolato + commit
   - Solo Tier A simple (vedi playbook 04 refactor)

6. **Tier 3 - App code adapt**:
   - Sequential fix dei call site rimanenti
   - Re-run full test suite

7. **Final verification**:
   - Full test + e2e (`pnpm test:e2e`)
   - Bundle size diff (`pnpm build --analyze`)
   - Deploy to staging + smoke test

8. **Rollback strategy**:
   - Ogni Tier in commit separato → granular revert
   - `git revert <commit>` per single tier rollback

**Setup files richiesti**:

```yaml
# .claude/agents/dependency-upgrader.md
---
name: dependency-upgrader
description: Plans and executes dependency upgrades tier-by-tier. Consults release notes via Context7 MCP.
model: opus
tools: Read, Edit, Bash, mcp__context7__*
---

Workflow:
1. Read package.json/pyproject.toml
2. For each candidate dep:
   - Get changelog via Context7 for {dep_name}
   - Identify BREAKING markers
3. Classify into Tier 0/1/2/3
4. Write upgrade-plan.md with mitigation per breaking change
5. On execute: upgrade ONE dep, run tests, commit, move next

NEVER batch multiple Tier 1 deps. Failures must be attributable.
NEVER skip test step. If test fails: stop, report, await user decision.
```

```markdown
<!-- upgrade-plan.md (template) -->
# Upgrade: Next.js 14 → 15

## Baseline
- Tag: pre-upgrade-20260514
- Test: 1247 pass, build 28s, bundle 487KB

## Tier 0 - Toolchain
- [ ] Node 18 → 20 (.nvmrc)
- [ ] pnpm 8 → 9

## Tier 1 - Core (sequential)
- [ ] next 14.2 → 15.0
  - BREAKING: async Request APIs (params, searchParams)
  - Codemod: `npx @next/codemod@latest next-async-request-api .`
  - Affected files: 23 (route handlers + page components)
- [ ] react 18 → 19
  - BREAKING: useRef requires arg
  - Codemod: `npx @next/codemod@latest react-19 .`

## Tier 2 - Feature libs (fan-out OK)
- [ ] date-fns 2 → 4 (sub-agent: 8 files)
- [ ] zod 3 → 4 (sub-agent: 34 files)

## Tier 3 - App code
- [ ] Fix custom Server Action types
- [ ] Update middleware signature
```

**Esempio di sessione tipo**:

```
User: aggiorna Next.js 14 a 15

[Plan Mode]
Claude: [dispatch dependency-upgrader]
        [Context7 MCP: fetch next-js v15 changelog]
        Breaking changes rilevati:
        1. Request APIs sono async (params/searchParams)
        2. fetch caching default off
        3. Minimum React 19
        4. Minimum Node 18.18

        Piano:
        Tier 0: Node 18.16 → 20 LTS
        Tier 1.1: next 14 → 15 (+ react 19)
        Tier 2: deps minori (8 librerie)
        Tier 3: 23 file con async params

User: vai

[Tier 0]
Claude: [Edit .nvmrc: 20.11.0]
        [Bash: nvm use && pnpm install && pnpm test]
        Tier 0 OK. Commit.

[Tier 1]
        [Bash: pnpm add next@15 react@19 react-dom@19]
        [Bash: npx @next/codemod@latest next-async-request-api .]
        Codemod modified 23 files.
        [Bash: pnpm test]
        Test 1198 pass, 49 fail (mostly route handler typing).
        [Read di 5 file failure samples]
        [Edit fix typing su 23 file - sequential]
        [Bash: pnpm test - 1247 pass]
        Tier 1 commit.

[Tier 2 fan-out]
        [Task dispatch 8 sub-agent upgrade]
        ... 7 success, 1 fail (zod 4 breaking)
[manual fix zod call sites]
[Tier 3 app code]
        Build verified, bundle 491KB (+4KB), accettabile.
```

**Metriche di successo**:
- Test pass rate post = pre (100%)
- Bundle size delta entro budget (es. +5%)
- Lighthouse / E2E score invariato
- Tempo: upgrade major framework in 2-4h (vs 1-2 giorni manuale)
- Ogni Tier revertibile in 1 comando

**Pitfalls comuni**:
- **Big bang upgrade** (tutto in 1 commit) → failure non attribuibile, revert distruttivo. Forza tier-by-tier.
- **Skippare codemod ufficiali** → Claude reimplementa da zero, miss edge case. Sempre check `@<framework>/codemod` o `jscodeshift` registry.
- **Test command lento** → Claude skip per tempo. Usa `--changed` o test path-mirato.
- **No changelog reading** → Claude indovina breaking. Forza Context7 MCP fetch del CHANGELOG.
- **Upgrade durante feature work** → mix di diff, blame loss. Branch dedicato chore/upgrade.
- **Lockfile non committato** → CI usa version diversa, surprise. Sempre `pnpm-lock.yaml` in commit.

**Varianti**:
- **.NET**: `.NET 10 Upgrade Planner` skill ufficiale Microsoft - segue stesso tier pattern
- **Python**: usa `uv` per atomicità (`uv add x@latest` + lock garantito). Hook per evitare `pip install` diretto.
- **Rust**: `cargo upgrade` (cargo-edit) + `cargo deny` per check security ad ogni step

**Fonti / Reference reali**:
- [Koder - Claude Code for dependency upgrades](https://koder.ai/blog/claude-code-dependency-upgrades-plan) - workflow tier-based originale
- [.NET 10 Upgrade Planner skill](https://mcpmarket.com/tools/skills/net-10-upgrade-planner) - skill ufficiale Microsoft
- [Trail of Bits /merge-dependabot](https://github.com/trailofbits/claude-code-config) - transitive dep mapping + matrix testing
- [DEV - Setup is the Strategy: product migration](https://dev.to/aws-builders/the-setup-is-the-strategy-how-i-orchestrated-a-product-migration-with-claude-code-b92) - migration end-to-end
- [Stripe customer story](https://claude.com/customers/stripe) - Scala→Java 10K LOC migration in 4 giorni
- [shinpr/claude-code-workflows](https://github.com/shinpr/claude-code-workflows) - production-ready migration workflows
