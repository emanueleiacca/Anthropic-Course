---
title: Framework - MCP custom vs Skill vs Tool API diretto
tags: [mcp, skill, tool, architecture, decision]
last_updated: 2026-05-14
audience: llm-advisory
---

# Framework: MCP server custom vs Skill vs Tool API diretto

**Decisione chiave**: cosa stai costruendo? Una **capacita riusabile cross-agent** (MCP), una **procedura/knowledge contestuale** (Skill), o una **singola funzione one-off** (Tool API)?

**TL;DR**:
- **Tool API diretto** = singola funzione, vita = una request
- **Skill** = procedura/knowledge, vita = filesystem persistente, no exec
- **MCP server** = capacita stateful, vita = processo running, multi-client

## Decision matrix primaria

| Caratteristica | Tool API | Skill | MCP server custom |
|----------------|----------|-------|-------------------|
| **Riusabile cross-agent?** | No (per-request) | Si (filesystem) | Si (multi-client) |
| **Side-effects esterni?** | Si | No (via tool) | Si |
| **Stateful?** | No | No | Si (server side) |
| **Auth/credenziali?** | Manual | No (deve usare MCP) | Si (env, OAuth) |
| **Distribution?** | Code inline | Git/marketplace | Package, marketplace |
| **Costo dev** | Bassissimo | Basso | Alto |
| **Discovery LLM** | Schema in API call | description in frontmatter | Tools list |
| **Versioning** | Code git | Folder semver | Server semver |
| **Test in isolamento** | Unit test | Markdown linter | Pytest + MCP inspector |

## Decision tree

```
Q1: Stai esponendo una CAPACITA' STATEFUL su sistema esterno?
├─ Si → Q2: La capacita serve a piu agent/client?
│   ├─ Si → SOLUTION: MCP server custom
│   │       (FastMCP, MCP SDK, deploy come stdio/HTTP)
│   └─ No → Q3: Ci sara riuso entro 3 mesi?
│       ├─ Si → MCP server (vale l'investimento)
│       └─ No → Tool API inline (one-shot)
│
└─ No (e KNOWLEDGE / PROCEDURE) → Q4: Coinvolge tool MCP esistenti?
    ├─ Si → Skill che orchestra MCP via allowed-tools fully-qualified
    └─ No → Q5: E generica o legata a sistema specifico?
        ├─ Generica → Skill standalone (no allowed-tools)
        └─ Sistema specifico ma read-only → Skill + tool MCP read-only
```

## Quando MCP server custom

**SI**:
- Esponi DB/SaaS/API legacy senza MCP esistente
- Necessita di **stato server-side** (cache, conn pool, session)
- Multiple agent / client devono accedere
- Auth complessa (OAuth flow, refresh token, RBAC)
- Tool latency-critical (server caldo)

**NO**:
- Per pure procedura testuale → Skill
- Per one-shot in script → Tool API
- Per documentation/knowledge → CLAUDE.md o Skill

**Cost**: 1-5 giorni dev iniziale, manutenzione continua, deploy infrastructure.

## Quando Skill

**SI**:
- Procedura ripetuta nel prompt
- Conoscenza di dominio (es. style guide, API conventions)
- Wrapper su tool MCP esistenti
- Workflow specializzato (deploy runbook, review checklist)
- Discovery automatica via description

**NO**:
- Skill che fa side-effect diretti (gira contro design)
- Skill con credenziali hardcoded (security)
- Skill che duplica MCP esistente

**Cost**: ore, no deploy, versione = file system.

## Quando Tool API diretto

**SI**:
- One-shot prototype
- Funzione semplice (es. calculator)
- Volume basso (no riuso)
- Logic dentro l'applicazione

**NO**:
- Tool con stato / connection pool → MCP
- Tool con auth complessa → MCP
- Riuso atteso → Skill (procedure) o MCP (capacita)

## Esempi concreti

### Esempio 1: "Pull richieste Jira e crea issue GitHub"

| Componente | Scelta | Why |
|------------|--------|-----|
| Accesso Jira | MCP Jira (esistente) | Stateful auth, tool catalog |
| Accesso GitHub | MCP GitHub (esistente) | Stateful auth, tool catalog |
| Procedura "mapping fields" | Skill `jira-to-github` | Procedura riusabile |
| Trigger | Slash command o cron | User intent |

### Esempio 2: "Esegui SQL custom su DB interno"

| Componente | Scelta | Why |
|------------|--------|-----|
| Connessione DB | MCP server custom (Postgres) | Conn pool, auth, multi-client |
| Procedura "report mensile" | Skill `monthly-report` | Riusa SQL templates |
| Result formatting | Tool API inline (1-shot) | Trasformazione locale |

### Esempio 3: "Genera commit message conforme conventional commits"

| Componente | Scelta | Why |
|------------|--------|-----|
| Git diff access | MCP git (esistente) | Tool standard |
| Convention rules | Skill `commit-message` | Knowledge, no side-effect |
| Hook PreCommit | Hook | Garanzia di esecuzione |

### Esempio 4: "Calcola IBAN check digit"

| Componente | Scelta | Why |
|------------|--------|-----|
| Logica check | Tool API inline | Funzione pura, no state |

(Niente skill, niente MCP. Overkill.)

### Esempio 5: "Esponi sistema CRM aziendale a 5 team"

| Componente | Scelta | Why |
|------------|--------|-----|
| API CRM | MCP server custom | Multi-client, auth centralizzata |
| Workflow team A | Skill `team-a-flow` | Procedure specifiche team |
| Workflow team B | Skill `team-b-flow` | ... |

## Pattern di combinazione raccomandato

```
Skill (orchestra procedura)
  ↓ allowed-tools: MCP:tool_name (fully qualified)
MCP server (esegue side-effect su sistema)
  ↓ chiama
External API/DB
```

CLAUDE.md inietta facts/conventions che la skill assume.
Hook garantisce esecuzione (es. PostToolUse run-tests).
Subagent isola context se task massivo.

## Anti-pattern

| Anti-pattern | Sintomo | Fix |
|--------------|---------|-----|
| Skill che chiama HTTP diretto via requests | Bypass del design Anthropic | Crea MCP server e usa via allowed-tools |
| MCP server che e solo docs | Overhead inutile | Spostalo come Skill |
| MCP server con 50+ tools | Token bloat, confusione | Split in 3-5 server tematici |
| Tool API inline con auth complessa | Credentials leak | MCP server con env vars |
| Skill duplica funzionalita MCP | Manutenzione doppia | Skill come orchestratore, MCP come capacity |
| MCP "monolite" per tutto un dominio | Single point of failure | Composable: 1 MCP per concern |
| Skill senza description (per LLM discovery) | Mai invocata | Frontmatter description obbligatoria |

## Quick reference

| "Voglio..." | Risposta |
|-------------|----------|
| "...accedere a Jira" | MCP Jira esistente |
| "...esporre nostro DB interno" | MCP custom |
| "...far seguire a Claude la nostra style guide" | Skill |
| "...calcolare un'espressione" | Tool API |
| "...integrare un SaaS senza MCP" | Build MCP custom (se riuso atteso) |
| "...automatizzare workflow di review" | Skill + MCP github + Subagent |
| "...iniettare context su ogni sessione" | CLAUDE.md o Hook UserPromptSubmit |

## Riferimenti

- MCP spec 2025-12 (modelcontextprotocol.io)
- Anthropic Skills cookbook (anthropics/skills su GitHub)
- "Skills vs Tools vs MCP vs Slash Commands" → [[../API-Tools/Skills/07-vs-tools-mcp.md]]
- MCP Ecosystem 2026 → [[../Agents-MCP/MCP Core/index.md]]
