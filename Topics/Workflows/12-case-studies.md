---
title: Playbook - Case studies Anthropic, Stripe, Trail of Bits
tags: [case-studies, anthropic, stripe, trail-of-bits, vercel, real-world]
last_updated: 2026-05-14
audience: llm-advisory
---

# Case studies reali: come usano Claude Code in produzione

### Reference di pattern attivi in produzione

**TL;DR**: Pattern documentati di adozione Claude Code in 4 organizzazioni: Anthropic interno (cross-team), Stripe (1370 eng), Trail of Bits (security audit), Vercel (platform plugin). Da consultare per inspiration su come scalare adozione in team grandi e per validare scelte di architettura.

**Contesti applicabili**: Reference cross-cutting

---

## Case A: Anthropic interno (cross-team)

**Source**: [How Anthropic teams use Claude Code](https://claude.com/blog/how-anthropic-teams-use-claude-code) + survey 132 engineer + 53 qualitative interview (Aug 2025).

**Headline**: "the majority of code is now written by Claude Code, with engineers focusing on architecture, product thinking, and continuous orchestration".

### Per-team patterns

**Data Infrastructure**:
- K8s debugging: dashboard screenshot → Claude Code guida menu-by-menu via gcloud UI → trova IP exhaustion in 20min (vs ore)
- Plain-text workflow per non-coder: finance team scrive "query dashboard X, run Y queries, output Excel" → Claude esegue
- **Raccomandazione interna**: usa MCP server (non CLI) per data sensitive - meglio logging + access control

**Product Engineering**:
- Bug fix in codebase unfamiliar: Claude propone fix, engineer review senza coinvolgere altro team
- Reduced cross-team dependencies

**Growth Marketing**:
- Agentic workflow processa CSV con metriche ad performance (centinaia di ad)
- Identifica underperformer + genera variations automaticamente

**Legal**:
- "Phone tree" prototype: routing query a lawyer giusto interno
- Built da non-engineer

**Security**:
- Custom skills per audit code
- Threat modeling assisted

### Pattern comuni cross-team
1. CLAUDE.md condivisi per documented workflow ricorrenti
2. MCP > CLI per data sensitive
3. Non-coder onboarding via plain-text workflow
4. Architecture focus per engineer senior, Claude handle implementation

---

## Case B: Stripe (enterprise rollout)

**Source**: [Customer story Stripe](https://claude.com/customers/stripe), MacVicar interviews.

**Scale**: 1,370 engineer all levels.

**Deployment**:
- Custom enterprise binary signed (no npm dependency chain - security)
- 2-3 mesi testing + iteration con Anthropic
- Bypassa supply chain attacks via signed binary

### Highlight win: Scala→Java migration
- 10,000 LOC migration
- 4 giorni con Claude Code (stima manuale: 10 engineer-week)
- Pattern: explore → plan → tier-by-tier (vedi playbook 05)

### Mental model per onboarding
"AI = new, capable engineer who knows all programming languages but lacks:
- Business context
- Codebase familiarity
- Stripe-specific conventions"

Implication: investire in CLAUDE.md, glossary, decision doc INTERNI per "fill the gap".

### Setup files visibili (open source)
- `stripe-ios/CLAUDE.md` - real production CLAUDE.md per SDK iOS
- `stripe-react-native/CLAUDE.md` - same per React Native
Pattern: conventions, build commands, testing, code style hard rules, BUT lean (<300 righe).

### Workflow CI integration
Claude Code monitora CI pipeline (GitHub + GitLab) e committa fix automatici.

---

## Case C: Trail of Bits (security firm)

**Source**: [trailofbits/claude-code-config](https://github.com/trailofbits/claude-code-config) + [trailofbits/skills](https://github.com/trailofbits/skills).

**Philosophy**: sandboxing, permission deny, structured oversight. **Run Claude in bypass-mode + OS isolation**, NON interactive approval.

### Settings stack
- Global CLAUDE.md ~2000 righe (eccezione documentata per security)
- Toolchain standards per language hard-coded:
  - Python: uv, ruff, ty
  - Node/TS: oxlint, vitest
  - Rust: clippy, cargo deny
  - Bash: shellcheck, shfmt

### Hooks bloccanti
1. Anti-`rm -rf` → suggerisce `trash`
2. Anti-direct-push main/master → forza branch

### Slash command custom
- `/fix-issue` - autonomous issue completion: research → impl → test → PR → self-review parallelo
- `/review-pr` - parallel review (pr-review-toolkit + Codex + Gemini), fix + push
- `/merge-dependabot` - transitive dep mapping, matrix testing, sequential merge

### Security skills (marketplace)
- `audit-context-building` - line-by-line First Principles
- `differential-review` - blast radius analysis
- `fp-check` - false positive verification
- Verification gate: 6 mandatory review prima di TRUE/FALSE POSITIVE verdict
- Static analysis: CodeQL, Semgrep, Slither (Solidity), Pyghidra (binary RE)

### Workflow methodology
**brainstorm → plan → execute → verify** - stesso pattern di obra superpowers ma adattato a security.

Per audit:
- Standard: linear single-pass checklist (bug semplici)
- Deep: full task-based orchestration con parallel sub-phases (complex bugs)
- Sempre 6 mandatory gate review prima verdict

### Sandboxing layered
1. `/sandbox` built-in (Seatbelt/bubblewrap)
2. Permission deny rules (.env, ~/.ssh)
3. Devcontainer per repo external
4. Remote droplets (Dropkit) per separation totale

### Context management
- `/clear` (NON `/compact`) tra task → preserva detail
- 1 session = 1 feature
- `/insights` weekly per identify pattern → iterate config

---

## Case D: Vercel (platform plugin)

**Source**: [Vercel plugin announcement](https://vercel.com/changelog/introducing-vercel-plugin-for-coding-agents) + [next-devtools-mcp](https://github.com/vercel/next-devtools-mcp).

**Pattern**: piattaforma fornisce MCP + skill bundle dedicato per loro stack.

### Vercel plugin per Claude Code
- 47+ skills coprenti la piattaforma Vercel
- Specialized "thinkers":
  - AI Architect
  - Deployment Expert
  - Performance Optimizer
- Real-time activity observation: legge file edit + terminal command per inject context dinamico

### next-devtools-mcp
MCP server ufficiale di Vercel per Next.js development:
- Tool: search Next.js doc
- Tool: browser automation per E2E
- CLAUDE.md template ufficiale
- create-next-app auto-genera AGENTS.md + CLAUDE.md

### Lessons
- Piattaforma owner DEVE fornire MCP + skill ufficiali per ridurre "context gap"
- Auto-genera CLAUDE.md durante project scaffolding
- Skills > raw doc: 47 skill specifici > 1 enorme doc

---

## Case E: obra/superpowers (community methodology)

**Source**: [github.com/obra/superpowers](https://github.com/obra/superpowers), [blog Jesse Vincent](https://blog.fsck.com/2025/10/09/superpowers/).

**Headline**: "transform Claude Code from code generator into senior AI developer".

### Skill bundle
1. `brainstorming` - Socratic refinement design
2. `writing-plans` - task 2-5min con paths + code completo
3. `test-driven-development` - RED-GREEN-REFACTOR enforced
4. `subagent-driven-development` - fresh subagent per task con two-stage review
5. `systematic-debugging` - 4-phase root cause
6. `code-review` - severity report contro plan
7. `using-git-worktrees` - isolated workspaces auto

### Iron Laws
- "no skill without failing test first"
- "evidence over claims"
- "systematic over ad-hoc"
- "complexity reduction" mandatory

### Adoption pattern
Singolo plugin `/plugin install obra/superpowers` → tutti i skill auto-activate sulle right condition.

---

## Pattern cross-case takeaways

| Pattern | Anthropic | Stripe | Trail of Bits | Vercel | superpowers |
|---------|-----------|--------|----------------|--------|-------------|
| CLAUDE.md investito | ✓ | ✓ lean | ✓ esteso | ✓ template | (via skills) |
| MCP > CLI for sensitive | ✓ | ✓ | ✓ | ✓ | n/a |
| Custom skills | ✓ | parziale | ✓ esteso | ✓ 47+ | ✓ framework |
| Parallel sub-agent | ✓ | ✓ migration | ✓ multi-reviewer | ✓ thinkers | ✓ fan-out |
| Sandboxing | ✓ MCP | ✓ binary signed | ✓ 4-layer | n/a | ✓ worktree |
| CI integration | ✓ | ✓ auto-fix | ✓ /review-pr | ✓ plugin | parziale |
| Iron rule TDD | parziale | parziale | per audit | n/a | ✓ enforced |
| Eval framework | ✓ | parziale | ✓ FP-check | n/a | ✓ skill eval |

**Conclusione operativa**:
- **Team < 10**: superpowers framework, lean CLAUDE.md, 3-5 MCP, OTel base
- **Team 10-100**: Vercel-style platform skill bundle + CI integration + per-team conventions
- **Team 100+** (enterprise): Stripe-style binary signed, layered sandbox, custom audit pipeline (Trail of Bits style)

**Fonti / Reference reali**:
- [How Anthropic teams use Claude Code](https://www.anthropic.com/news/how-anthropic-teams-use-claude-code) - blog ufficiale + PDF report
- [Stripe customer story](https://claude.com/customers/stripe) - 1370 eng rollout
- [stripe-ios/CLAUDE.md](https://github.com/stripe/stripe-ios/blob/master/CLAUDE.md) - production iOS SDK CLAUDE.md
- [trailofbits/claude-code-config](https://github.com/trailofbits/claude-code-config) - opinionated security setup
- [Vercel changelog plugin](https://vercel.com/changelog/introducing-vercel-plugin-for-coding-agents) - 47 skills platform
- [obra/superpowers](https://github.com/obra/superpowers) - community methodology framework
- [Ernest Chiang - How Anthropic Teams Use Claude Code](https://www.ernestchiang.com/en/posts/2025/how-anthropic-teams-use-claude-code/) - reaction notes + extracts
- [Codingscape - How Anthropic engineering teams use Claude Code every day](https://codingscape.com/blog/how-anthropic-engineering-teams-use-claude-code-every-day)
