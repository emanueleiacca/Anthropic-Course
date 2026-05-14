---
title: Playbook - Debug session sistematica
tags: [debug, root-cause, debugging, parallel-agents, eval-driven, memory]
last_updated: 2026-05-14
audience: llm-advisory
---

# Debug session sistematica

### Playbook: 4-phase root cause debugging

**TL;DR**: Workflow di debugging che evita il "guess-and-check": 4 fasi (Reproduce → Localize → Root Cause → Fix+Verify). Usa parallel agents per ipotesi concorrenti, memory tool per accumulare evidence cross-session, eval-driven verification. Pattern di obra/superpowers `systematic-debugging` skill.

**Contesti applicabili**: Tutti

**Pre-requisiti**:
- Bug riproducibile (anche se intermittente) oppure stack trace/log
- Test runner per scrivere regression test
- `memory` tool attivo per session lunghe (Claude Code 2.x +)

**Workflow step-by-step**:

1. **Phase 1 - Reproduce**:
   - Scrivi PRIMA un test che fallisce mostrando il bug (regression test)
   - Se intermittente: scrivi loop test che genera la condizione
   - Save evidence (stack trace, log) in `debug-notes.md` (memory)

2. **Phase 2 - Localize (parallel hypothesis)**:
   - Genera 3-4 ipotesi concorrenti
   - **Parallel sub-agent dispatch** - uno per ipotesi
   - Ogni sub-agent: legge codice rilevante, valida o smentisce con evidence concreta
   - Output: ranking ipotesi per probabilita

3. **Phase 3 - Root Cause**:
   - Ipotesi piu probabile: deep-dive isolato
   - Tecniche obra: **condition-based waiting** (no sleep), **defense-in-depth**, **falsifiable assertion**
   - Validate root cause scrivendo test che simula la condizione precisa

4. **Phase 4 - Fix + Verify**:
   - Fix minimale che fa passare il regression test
   - Run full test suite (no collateral damage)
   - Add eval entry: se "bug class" ricorrente, aggiungi a golden dataset

5. **Documentation**:
   - Aggiorna CLAUDE.md se rivela bias/gotcha (es. "remember: zod transform is async")
   - Salva pattern in memory per future session

**Setup files richiesti**:

```yaml
# .claude/skills/systematic-debugging/SKILL.md
---
name: systematic-debugging
description: |
  Activates when user reports a bug or test failure.
  Enforces 4-phase root cause approach instead of guess-and-check.
---

Phase 1 REPRODUCE:
- Write a failing test that captures the bug
- If non-deterministic: write a loop test or use deterministic seed
- Save symptom in debug-notes.md

Phase 2 LOCALIZE (parallel):
- Generate 3-4 falsifiable hypotheses
- Dispatch one subagent per hypothesis with prompt:
  "Investigate hypothesis: X. Evidence FOR/AGAINST. Return verdict."
- Rank hypotheses by evidence weight

Phase 3 ROOT CAUSE:
- Take top hypothesis, deep-dive
- Use condition-based waiting (NEVER sleep()), defense-in-depth, exhaustive case analysis
- Validate by writing test that fails ONLY under the precise condition

Phase 4 FIX + VERIFY:
- Minimal fix to pass regression test
- Run full suite, check for collateral damage
- If bug class recurring: add to eval golden set

ANTI-PATTERN: "let me just try X" loop without hypothesis.
ANTI-PATTERN: fix without reproduction test (no regression guard).
```

```yaml
# .claude/agents/hypothesis-investigator.md
---
name: hypothesis-investigator
description: Investigates ONE hypothesis with evidence-based verdict. Used in parallel debug.
model: sonnet
tools: Read, Grep, Glob, Bash
---

Input: { hypothesis: string, context: { stack_trace, bug_description } }

Steps:
1. Restate hypothesis in falsifiable form
2. Identify code/log evidence FOR and AGAINST
3. Run minimal Bash check (grep error log, check version, etc.)
4. Output:
   VERDICT: CONFIRMED | LIKELY | UNLIKELY | DISPROVEN
   EVIDENCE FOR: [list]
   EVIDENCE AGAINST: [list]
   CONFIDENCE: 0-100%

DO NOT modify files. DO NOT fix the bug. INVESTIGATE ONLY.
```

**Esempio di sessione tipo**:

```
User: prod API ritorna 500 random ~1% delle richieste su /api/orders. Log:
      "PrismaClientUnknownRequestError: Server has closed connection"

[systematic-debugging skill activates]
Claude: Phase 1 REPRODUCE:
[Write test t/orders-connection.test.ts that hammers endpoint 200x]
[Bash: pnpm test orders-connection -- ~2/200 fail]
Reproduction confirmed. Save evidence to debug-notes.md.

Phase 2 LOCALIZE: 4 ipotesi parallele.
[Task dispatch 4 hypothesis-investigator subagents]

H1: Connection pool exhaustion (default 10, peak 30 req/s)
H2: Idle connection killed by Postgres server (default 10min)
H3: Network blip Render → Postgres (transient)
H4: Long-running migration locking table

[parallel results]
H1: LIKELY 75% - pool size 10, log shows ConnectionAcquisitionError peak
H2: LIKELY 60% - pgbouncer idle_timeout 600, our pool no keepalive
H3: UNLIKELY 20% - no Render incidents in window
H4: DISPROVEN - no migration in 7gg

Phase 3 ROOT CAUSE: top hypothesis H1+H2 combined.
Deep dive: Prisma connection_limit not set, defaults 10. PgBouncer kills idle 10min.
Write isolated test that ages connection then queries:
[Edit test with sleep(11*60*1000) — NO, use condition-based:
 simulate via pgbouncer.kill_client_after_idle]
[Test fails with same error - CONFIRMED]

Phase 4 FIX:
1. Set `connection_limit=20&pool_timeout=10` in DATABASE_URL
2. Add `?pgbouncer=true&statement_cache_size=0` for pgbouncer compat
3. Add prisma middleware for connection retry x2 on KnownConnectionError

[Edit prisma.ts + .env]
[Run full test: 200/200 pass]
[Run regression test 1000x in stress: 1000/1000 pass]
Fix verified.

Update CLAUDE.md:
+ ## Postgres notes
+ Always set connection_limit explicitly when using PgBouncer.
+ Idle connections die after 600s - configure keepalive or retry middleware.

Save to memory: pattern "prisma+pgbouncer connection-limit gotcha".
```

**Metriche di successo**:
- Bug rezoluto al primo PR (no follow-up fix per stesso bug class)
- Regression test in suite ferma il bug se reintrodotto
- Time to root cause: <1h per bug critical (vs ore di guess-check)
- Memory accumula gotchas → future session prevent stessi errori

**Pitfalls comuni**:
- **Skip reproduction**: fix senza test = no regression guard, bug torna. FORZA Phase 1.
- **Single hypothesis tunnel vision**: Claude si attacca alla prima ipotesi, ignora evidence contrary. Forza 3-4 parallel.
- **`sleep(5000)` per "wait"**: race condition non risolta, solo nascosta. Usa condition-based polling.
- **Fix sintomo non causa**: try/catch swallow error = bug invisibile. Forza root cause prima.
- **No memory persist**: prossima session ricomincia da zero. Forza save in `memory` o `CLAUDE.md` gotchas section.
- **Sub-agent senza tool whitelist**: hypothesis-investigator scrive codice = perde isolamento. Lock down a Read/Grep/Bash.

**Varianti**:
- **Production debugging**: vedi playbook 07 con OTel tracing. Add subagent che query Langfuse/Honeycomb per evidence.
- **Flaky test**: scrivi loop test 100x prima di dichiarare fix
- **Performance bug**: vedi playbook 09. Phase 2 include profiler attach.

**Fonti / Reference reali**:
- [obra/superpowers systematic-debugging skill](https://github.com/obra/superpowers) - 4-phase methodology originale
- [Anthropic - Demystifying evals for AI agents](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents) - eval-driven verification
- [Anthropic Data Infrastructure case](https://claude.com/blog/how-anthropic-teams-use-claude-code) - K8s pod scheduling debug via dashboard screenshots, 20min saved
- [TribeAI claude-evals](https://github.com/TribeAI/claude-evals) - eval framework con regression detector
- [PADISO - Evaluations for Claude Agents Beyond Vibe Checks](https://www.padiso.co/blog/evaluations-claude-agents-beyond-vibe-checks/)
- [orchestrator.dev - Memory best practices 2026](https://orchestrator.dev/blog/2026-04-06--claude-code-agent-memory-2026/) - memory tool patterns
