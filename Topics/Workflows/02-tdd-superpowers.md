---
title: Playbook - TDD con superpowers (brainstorm→spec→plan→TDD)
tags: [tdd, superpowers, obra, brainstorm, spec, plan, red-green-refactor]
last_updated: 2026-05-14
audience: llm-advisory
---

# TDD con superpowers (obra methodology)

### Playbook: TDD-driven feature development

**TL;DR**: Workflow di Jesse Vincent (obra/superpowers) per aggiungere feature in modo affidabile: 4 fasi (brainstorm → spec → plan → subagent-driven TDD execution). Trasforma Claude da "code generator" a "senior dev disciplinato". Da usare per ogni feature non triviale.

**Contesti applicabili**: Web | CLI (richiede test framework solido)

**Pre-requisiti**:
- Plugin `obra/superpowers` installato (`/plugin install obra/superpowers`) o equivalente DIY skills
- Test runner configurato e veloce (<10s full suite)
- Git pulito, branch dedicato

**Workflow step-by-step**:

1. **Brainstorming skill** - Claude attiva la skill `brainstorming` PRIMA di scrivere codice. Pone domande, esplora alternative, presenta il design in chunk leggibili. Output: design doc salvato.

2. **Spec writing** - Una volta validato il design, viene generato uno spec doc strutturato (acceptance criteria, edge case, out-of-scope esplicito).

3. **Writing plans skill** - Il plan viene scritto come una serie di task da 2-5 minuti ciascuno con:
   - File path esatti
   - Codice completo (no "TBD", no "similar to task N")
   - Step di verifica con comando + output atteso
   - Commit point frequenti

4. **Git worktree isolation** - Crea worktree dedicato per la feature (`using-git-worktrees` skill).

5. **Subagent-driven-development** - Dispatch di un fresh subagent PER task con due-stage review:
   - Stage 1: compliance con la spec
   - Stage 2: qualita codice (TDD, YAGNI, DRY)

6. **TDD red-green-refactor enforced** per ogni task:
   - **RED**: scrivi UN test che fallisce, osserva il fail
   - **GREEN**: minimal code per passare il test (no extras)
   - **REFACTOR**: dedup, clarity, commit

7. **Code review skill** - Review automatico contro il plan: severity report. Issue critici bloccano l'avanzamento.

8. **Iron Law** (obra): "no skill without failing test first". Stesso principio per process documentation.

**Setup files richiesti**:

```yaml
# .claude/skills/brainstorming/SKILL.md (estratto)
---
name: brainstorming
description: |
  Activate before writing code for any non-trivial feature.
  Refines ideas through Socratic questions, explores 2-3 alternatives,
  presents design in digestible chunks for user validation.
  Saves design.md to specs/ directory.
---
PHASE 1 - Clarify: ask 3-5 questions about constraints, scale, user
PHASE 2 - Explore: present 2-3 design alternatives with tradeoffs
PHASE 3 - Converge: pick winner, write design.md with sections:
  Problem | Solution | Non-goals | Architecture | Open questions
```

```yaml
# .claude/skills/writing-plans/SKILL.md (estratto)
---
name: writing-plans
description: |
  Generate implementation plans for multi-step tasks.
  Target audience: enthusiastic junior engineer with no context.
  Each task = 2-5 minutes. Every task has exact paths + complete code.
---
Structure:
# Feature Name
**Goal**: one-sentence outcome
**Architecture**: 2-3 sentences
**Tech Stack**: explicit

## File Structure
| Path | Action | Responsibility |

## Task N: Component
**Files:** Create src/foo.ts | Modify src/bar.ts | Test src/foo.test.ts
- [ ] Step 1: write failing test (RED)
- [ ] Step 2: minimal implementation (GREEN)
- [ ] Step 3: refactor + commit

PROHIBITED: "TBD", "implement later", "add error handling" without spec
REQUIRED: complete code blocks, exact commands with expected output
```

```yaml
# .claude/skills/test-driven-development/SKILL.md (estratto)
---
name: test-driven-development
description: Enforces RED-GREEN-REFACTOR. Activates when writing new code or fixing bugs.
---
RED: write ONE failing test. Run it. Confirm fail message is informative.
GREEN: write MINIMAL code to pass. No speculative features. No "while I'm here".
REFACTOR: only when green. Remove duplication. Commit.

Iron Law: if test passes, implementation is COMPLETE. Stop adding code.
If test fails, fix IMPLEMENTATION not test (unless test is buggy - rare).
```

**Esempio di sessione tipo**:

```
User: aggiungi feature "export workspace to CSV" alla SaaS

[brainstorming skill activates]
Claude: Prima di scrivere codice, qualche domanda:
        1. CSV deve essere streaming (workspace grandi) o sync?
        2. Quali campi: solo dati base o include relations (jobs, runs)?
        3. Export sincrono nel handler o async via job queue?
User: streaming, include jobs ultimi 30gg, async via BullMQ

[design.md scritto in specs/2026-05-14-csv-export.md]
Claude: Design pronto. Vuoi che generi il plan?
User: yes

[writing-plans skill activates]
[plan.md generato con 6 task: Task 1 stream serializer, Task 2 BullMQ job,
 Task 3 route handler, Task 4 frontend trigger, Task 5 e2e test, Task 6 docs]

[using-git-worktrees skill: crea ../proj-csv-export worktree]
[subagent-driven-development: dispatch subagent Task 1]

Subagent Task 1: RED - writing test for stream serializer
[Edit src/lib/csv-stream.test.ts]
[Bash: pnpm test csv-stream -- FAIL: expected Readable stream]
GREEN - implementing minimal
[Edit src/lib/csv-stream.ts]
[Bash: pnpm test csv-stream -- PASS]
REFACTOR - extract row formatter helper
[Edit src/lib/csv-stream.ts]
[Bash: pnpm test csv-stream -- PASS]
[Bash: git commit -m "feat: csv stream serializer"]

[code-review skill on Task 1]
Reviewer: 0 critical issues. 1 suggestion (consider chunk size 16KB).
Continuo con Task 2...
```

**Metriche di successo**:
- Feature shippata con test coverage >80% sul nuovo codice
- 0 rollback nelle 24h post-deploy
- design.md + plan.md committati come artefatti (review-able da peer)
- Time-to-merge < 2x del manual workflow (in cambio di maggior qualita)

**Pitfalls comuni**:
- **Skippare brainstorming** → Claude implementa la prima idea che gli viene, miss requirements impliciti. Forza la skill.
- **Plan troppo vago** ("add error handling", "similar to X") → subagent non sa cosa fare. Rifiuta il plan se contiene placeholder.
- **Test post-implementation** → non e TDD, e regression test. Forza scrittura test PRIMA dell'impl.
- **Subagent senza fresh context** → contesto del main si propaga, perdi i benefici di isolamento. Usa `Task` tool con prompt completo.
- **No git worktree** → subagent paralleli si pestano i piedi su file system. Worktree obbligatori per parallelizzare.

**Varianti**:
- **Web**: aggiungi step 4.5 "Playwright E2E test PRIMA dell'unit test" se feature UI-critical
- **CLI**: salta brainstorming se feature triviale (add flag, simple command); applica per cmd con state mgmt

**Fonti / Reference reali**:
- [obra/superpowers GitHub](https://github.com/obra/superpowers) - framework originale di Jesse Vincent
- [Superpowers: how I'm using coding agents in October 2025](https://blog.fsck.com/2025/10/09/superpowers/) - post originale di obra
- [writing-plans SKILL.md](https://github.com/obra/superpowers/blob/main/skills/writing-plans/SKILL.md) - template plan obra
- [alexop.dev - Forcing Claude Code to TDD](https://alexop.dev/posts/custom-tdd-workflow-claude-code-vue/) - custom TDD slash command Vue esempio
- [aihero.dev - My Skill Makes Claude Code GREAT At TDD](https://www.aihero.dev/skill-test-driven-development-claude-code) - skill TDD evaluation-driven
- [Trail of Bits skills - brainstorm→plan→execute→verify](https://github.com/trailofbits/skills) - stessa methodology applicata a security audit
