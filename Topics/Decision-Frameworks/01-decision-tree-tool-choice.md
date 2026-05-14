---
title: Decision Tree - Scegliere il giusto strumento Claude
tags: [decision-tree, routing, skill, mcp, subagent, hook, claude-md]
last_updated: 2026-05-14
audience: llm-advisory
---

# Decision Tree: Scegliere il giusto strumento Claude

**TL;DR**: percorso binario per arrivare in <6 domande alla soluzione corretta tra **MCP / Skill / Subagent / Hook / CLAUDE.md / Slash Command / Tool API diretto**.

## Decision Tree principale

```
Q1: Il task richiede un'AZIONE su sistema esterno (API, DB, filesystem remoto, SaaS)?
├─ Si → Q2: Esiste gia un MCP server ufficiale/community?
│   ├─ Si → SOLUTION: USA MCP server esistente
│   │       (cfr. mcp-ecosystem catalog)
│   └─ No → Q3: L'azione e business-critical / riusabile da piu agent?
│       ├─ Si → SOLUTION: BUILD custom MCP server (FastMCP/SDK)
│       └─ No → SOLUTION: Tool API diretto inline (one-shot)
│
└─ No → Q4: Il task richiede KNOWLEDGE/PROCEDURE persistente riusabile?
    ├─ Si → Q5: La procedura e specifica al progetto corrente?
    │   ├─ Si → Q6: Le info sono <40 righe e SEMPRE rilevanti?
    │   │   ├─ Si → SOLUTION: CLAUDE.md (project memory)
    │   │   └─ No → SOLUTION: Skill in .claude/skills/ con paths glob
    │   └─ No (cross-project) → SOLUTION: Skill in ~/.claude/skills/ (user-scope)
    │
    └─ No → Q7: Il task e una ESECUZIONE in punto deterministico del lifecycle?
        ├─ Si → SOLUTION: Hook (PreToolUse/PostToolUse/SessionStart/Stop)
        └─ No → Q8: Il task richiede CONTEXT ISOLATION (esplorazione massiva)?
            ├─ Si → SOLUTION: Subagent (Explore/Plan/code-reviewer/general-purpose)
            └─ No → Q9: L'utente lo invochera spesso con shortcut?
                ├─ Si → SOLUTION: Slash command (skill con disable-model-invocation)
                └─ No → SOLUTION: Prompt inline / nessun tooling
```

## Tabella di disambiguazione rapida

| Sintomo nel prompt utente | Strumento primario | Strumento secondario |
|---------------------------|-------------------|----------------------|
| "Apri/Crea/Modifica file remoto" | MCP filesystem/github | Skill con allowed-tools |
| "Quando faccio X, fai sempre Y" | Hook (PreToolUse/PostToolUse) | Skill con disable-model-invocation |
| "Segui le nostre convention di codice" | CLAUDE.md (<40 righe) o Skill | Hook UserPromptSubmit per inject |
| "Esplora il repo e dimmi come funziona" | Subagent Explore | Skill systematic-debugging |
| "Code review approfondita" | Subagent code-reviewer | Skill + MCP github |
| "Genera report da multiple fonti" | Multi-agent orchestrator + subagent | MCP per ogni fonte |
| "Esegui test e linter dopo edit" | Hook PostToolUse | Skill con allowed-tools |
| "Memorizza decisioni architetturali" | Memory tool / CLAUDE.md | Skill knowledge-base |
| "Workflow di deploy ripetuto" | Skill + MCP (k8s/aws) | Slash command |
| "Conversione formato (PDF→MD, CSV→JSON)" | Skill ufficiale (anthropics/skills) | Code Execution tool |
| "Triage 500 issue GitHub" | Batch API + MCP github | Subagent parallel |
| "Long-running agent (>1h)" | Agent SDK + memory + checkpointing | Managed Agents |
| "Test su input untrusted" | Subagent isolato + sandbox | Hook security |

## Decision tree dettagliato per scenari ambigui

### Skill vs CLAUDE.md

```
Q: L'info e:
├─ Sempre rilevante in OGNI sessione? → CLAUDE.md
├─ Rilevante solo per file specifici? → Skill con paths glob
├─ Procedurale (steps)? → Skill
├─ Factual (URL, naming convention)? → CLAUDE.md
└─ >40 righe? → Skill (CLAUDE.md va tenuto lean)
```

### MCP vs Skill in combo

```
Q: Il task richiede BOTH azione esterna AND procedura?
├─ Si → Skill che chiama MCP via allowed-tools fully-qualified
│       Es. allowed-tools: GitHub:get_issue GitHub:list_commits
└─ Solo azione → MCP diretto, no skill wrapper
```

### Subagent vs Skill

```
Q: Il task:
├─ Richiede >20K token di esplorazione? → Subagent (fork context)
├─ Riusa un workflow noto step-by-step? → Skill
├─ Deve continuare in parallelo ad altro? → Subagent
└─ Restituisce risultato deterministico? → Skill
```

### Hook vs Skill

```
Q: L'esecuzione deve essere:
├─ Garantita 100% (no LLM decide)? → Hook
├─ Contestuale (LLM decide quando)? → Skill
├─ Bloccante (deny tool call)? → Hook con exit 2
└─ Suggerimento prompt-level? → Skill o CLAUDE.md
```

## Tabella riassuntiva: caratteristiche per strumento

| Strumento | Esecuzione | Discovery | Stateful | Side-effects | Scope |
|-----------|-----------|-----------|----------|--------------|-------|
| **MCP server** | LLM decide | Tool descriptions | Si (server-side) | Si | Sessione |
| **Skill** | LLM decide via description | Frontmatter | No (path I/O) | Via tool | Project/user |
| **Subagent** | Tool invocation | description in agent.md | No (fresh context) | Via tool | Sessione |
| **Hook** | Harness (deterministico) | settings.json | File-system | Si | Project/user/global |
| **CLAUDE.md** | Auto-load (UserPromptSubmit) | Auto | Read-only | No | Project/user/global |
| **Slash cmd** | User invoca esplicito | Tab-complete | No | Via tool | Project/user |
| **Tool API** | LLM decide | Schema in API call | No | Si | Per-request |

## Pattern di combinazione tipici

| Scenario | Stack consigliato |
|----------|-------------------|
| "Code reviewer batterie incluse" | Hook PreCommit → Subagent code-reviewer → Skill review-checklist → MCP github |
| "Onboarding nuovo dev" | CLAUDE.md (overview) + Skill how-to-deploy + MCP filesystem |
| "Daily standup automation" | Hook SessionStart → Skill standup + MCP slack/linear |
| "Bug triage from issue tracker" | Subagent + Skill triage-bug + MCP jira/github |
| "Architecture decision recording" | Skill adr-writer + CLAUDE.md (link to ADRs) |

## Anti-pattern del routing

- **Usare MCP per pure procedure**: se non c'e side-effect esterno, e Skill.
- **Mettere 500 righe in CLAUDE.md**: split in skill con paths.
- **Subagent per task brevi**: overhead context isolation > beneficio se <5K token.
- **Hook per logica condizionale complessa**: meglio skill con allowed-tools.
- **Skill che duplica MCP**: la skill deve coordinare, non re-implementare.

## Fonti

- Anthropic Skills cookbook (claude-cookbooks)
- MCP spec 2025-12 + roadmap 2026
- Claude Code docs (hooks, settings.json, subagents)
- Trail of Bits "Skills security review" (2026-Q1)
