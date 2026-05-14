---
title: Playbook - Refactor large-scale (planner-executor + fan-out)
tags: [refactor, large-scale, planner, fan-out, sub-agent, split-merge, checkpoint]
last_updated: 2026-05-14
audience: llm-advisory
---

# Refactor large-scale (planner-executor + fan-out)

### Playbook: Split-and-merge refactor pattern

**TL;DR**: Per refactor che tocca 20+ file (deprecazione funzione, rename API, migration pattern), usa pattern primary-orchestrator + sub-agent fan-out fino a 10 paralleli. Ogni sub-agent ha contesto isolato e small (max 1-3 file). Checkpoint con `Esc Esc` per rollback. Pattern usato in produzione per migration di 75+ file.

**Contesti applicabili**: Web | CLI (codebase grandi)

**Pre-requisiti**:
- Test suite verde su `main` come baseline
- Git pulito, branch `refactor/<nome>`
- Plan mode disponibile (Shift+Tab x2)
- Memoria/checkpoint attivi

**Workflow step-by-step**:

1. **Explore phase** (Plan Mode read-only): primary agent fa Grep/Glob per identificare TUTTE le occorrenze. Output: `refactor-plan.md` con file list + classificazione (simple replace / context-dependent / breaking).

2. **Categorize**:
   - Tier A (simple): pure string replace → batch automation
   - Tier B (signature change): refactor 1 file alla volta con test re-run
   - Tier C (semantic change): manual review necessaria, no fan-out

3. **Generate plan** (writing-plans skill obra-style): N task atomici, ognuno = un sub-agent.

4. **Snapshot baseline**: `Esc Esc` per checkpoint, OPPURE git tag `refactor-baseline-$(date +%s)`.

5. **Fan-out execution** - Primary dispatch via Task tool:
   - Fino a 10 sub-agent in parallelo per Tier A
   - 3-4 sub-agent per Tier B (eval result before next)
   - Sequential per Tier C

6. **Per-subagent task**: contesto minimale (file path + transformation rule + test command). Sub-agent esegue + valida con test locale.

7. **Merge phase**: primary attende tutti, raccoglie risultati, risolve conflitti. Esegue test suite completo.

8. **Eval regression**: confronta diff metrics (LOC modified, test count, coverage) con baseline.

9. **Iterative**: se >5% test fail, rollback con `/rewind` → re-plan con error context.

**Setup files richiesti**:

```yaml
# .claude/agents/planner.md
---
name: planner
description: Plans large refactors. Categorizes changes (simple/signature/semantic). Outputs refactor-plan.md.
model: opus
tools: Read, Grep, Glob, Bash(rg*, ast-grep*)
---

When asked to plan a refactor:
1. Run rg/ast-grep to find ALL occurrences
2. Sample 10 occurrences, classify each:
   - SIMPLE: pure rename, string replace
   - SIGNATURE: argument count/type change
   - SEMANTIC: behavior change, requires per-site reasoning
3. Write refactor-plan.md:
   ## Tier A SIMPLE (N files): batch fan-out
   - list paths
   ## Tier B SIGNATURE (M files): sequential w/ test
   - list paths + signature mapping
   ## Tier C SEMANTIC (K files): manual per-site
   - list paths + reasoning needed
4. Estimate effort + risk per tier
```

```yaml
# .claude/agents/refactor-executor.md
---
name: refactor-executor
description: Executes single-file refactor task with isolated context. Verifies via test command.
model: sonnet
tools: Read, Edit, Bash
---

Input: { file_path, transformation, test_command }

Steps:
1. Read file
2. Apply transformation
3. Run test_command
4. If pass: report SUCCESS with diff summary
5. If fail: report FAIL with error message + revert hint

DO NOT modify other files. DO NOT skip test.
If file structure doesn't match expectation, report MISMATCH (don't guess).
```

```markdown
<!-- refactor-plan.md (template generato) -->
# Refactor: deprecate `legacyAuth()` → `auth.v2.verify()`

## Baseline
- git tag: refactor-baseline-1715698800
- test suite: 1247 tests, 100% pass
- LOC: 87,432

## Tier A SIMPLE (52 files): batch fan-out
Direct replace `legacyAuth(token)` → `auth.v2.verify(token)`:
- src/api/users.ts:23
- src/api/orders.ts:15
- ... (50 more)

Test cmd: `pnpm test -- --filter=affected`

## Tier B SIGNATURE (18 files): sequential
Old: `legacyAuth(token, opts?)` → New: `auth.v2.verify({ token, ...opts })`
Per-file mapping needed:
- src/middleware/auth.ts: opts={ strict: true } → { ...opts, strict: true }
...

## Tier C SEMANTIC (7 files): manual review
Behavior change: v2 throws on expired token (v1 returned null).
Per-site error handling refactor needed.
```

**Esempio di sessione tipo**:

```
User: deprecate `legacyAuth` ovunque in favore di `auth.v2.verify`

[Plan Mode activated via Shift+Tab x2]
Claude: [dispatch planner subagent]

Planner: 77 file usano legacyAuth. Categorizzati:
- Tier A: 52 file (simple replace)
- Tier B: 18 file (signature change)
- Tier C: 7 file (semantic - null vs throw)
Plan written to refactor-plan.md.

User: approva plan, exit plan mode, esegui Tier A in parallelo
[Esc Esc - checkpoint baseline]

Claude: [Task tool dispatch 10 paralleli sub-agent refactor-executor]
        File 1-10 in flight...
[Task results: 10 SUCCESS]
        Batch 2: file 11-20...
[Task results: 9 SUCCESS, 1 MISMATCH src/legacy/old.ts]
Claude: Sub-agent ha trovato pattern inatteso in old.ts (chiamata indiretta).
        Move to Tier C list. Continue Tier A...
[Batch 3-6 dispatched]

[final merge]
Claude: Tier A done: 51/52 success.
        Running full test: pnpm test
[Test: 1247 pass, 0 fail]
        Tier A complete. Continue with Tier B sequential?
User: yes
[Sequential Tier B with test re-run per file]
```

**Metriche di successo**:
- Test pass rate post-refactor = pre-refactor (zero regression)
- Time to complete: 75 file refactor in 30-45min (vs 1-2 giorni manuale)
- 0 file orphan (dimenticati)
- 1 commit per Tier (revertibile granulare)

**Pitfalls comuni**:
- **Fan-out senza isolamento**: sub-agent paralleli scrivono lo stesso file → corruption. Verifica file list non si sovrappone.
- **Skip baseline tag**: rollback complicato. Sempre `git tag` PRIMA di iniziare.
- **No categorization**: tratti tutto come Tier A → break su Tier B/C. Forza il planner step.
- **Test command pesante per sub-agent** (full suite 5min) → fan-out impallato. Usa `--filter=affected` o test isolato per file.
- **Tier C tentato in fan-out** → context insufficiente, sub-agent guess. Forza sequenziale con primary che mantiene memoria.
- **Compaction durante refactor lungo** → primary perde plan. Salva plan su file e re-leggi periodicamente.

**Varianti**:
- **Codebase Rust/Go**: usa `ast-grep` invece di `rg` per pattern AST-aware
- **Monorepo**: aggiungi step "package-aware" per evitare cross-package refactor in singolo sub-agent

**Fonti / Reference reali**:
- [MindStudio - Claude Code Split-and-Merge Pattern](https://www.mindstudio.ai/blog/claude-code-split-and-merge-pattern-sub-agents) - pattern fan-out fino a 10 sub-agent
- [Skywork - Claude Code for refactoring legacy code](https://skywork.ai/blog/how-to-use-claude-code-for-refactoring-legacy-code/) - 75-file deprecation case
- [zachwills - Claude Code Subagents to Parallelize Development](https://zachwills.net/how-to-use-claude-code-subagents-to-parallelize-development/)
- [Anthropic - Enabling Claude Code to work more autonomously](https://www.anthropic.com/news/enabling-claude-code-to-work-more-autonomously) - checkpoint & autonomous patterns
- [Stripe case study](https://claude.com/customers/stripe) - 10K LOC Scala→Java in 4 giorni (10 engineer-week stimati)
- [wshobson/agents - 16 workflow orchestrators](https://github.com/wshobson/agents) - presets per parallel reviewer/refactor
