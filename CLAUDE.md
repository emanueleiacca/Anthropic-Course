# Anthropic Academy Knowledge Base - Guida per Claude

## Cos'è questo repo

Knowledge base in Markdown per lo studio di Anthropic, Claude, sistemi agentici, MCP, prompting, API e Claude Code. Costruita da note esportate e riorganizzata gerarchicamente.

## Struttura

```
.
├── Topics/          # Tassonomia principale per concetto
│   ├── Foundations/
│   ├── Prompting/   (+ Advanced/)
│   ├── API-Tools/
│   │   ├── Claude API/
│   │   ├── Agent Tooling/
│   │   └── Skills/                  # Skills ecosystem (panoramica, API, custom, composition)
│   ├── Agents-MCP/
│   │   ├── Agent Patterns/
│   │   ├── MCP Core/                # + MCP-Ecosystem-2026.md (transport, auth, advanced)
│   │   ├── Production/              # Multi-agent, memory, observability, eval, security
│   │   ├── Cowork/
│   │   └── Retrieval/
│   ├── Claude Code/                 # + Claude-Code-Advanced.md (hooks, settings, sub-agents)
│   ├── Decision-Frameworks/         # Routing operativo: lookup task→solution, decision tree
│   ├── Workflows/                   # Playbook end-to-end real-world (12 playbook)
│   ├── Stacks-Catalog.md            # Stack curato per 4 contesti dev
│   └── Ethics-Safety/
├── Starter-Templates/               # CONFIGURAZIONI CLONABILI per 4 contesti dev
│   ├── web-fullstack/               # Next.js + React + Postgres + Redis (template completo)
│   ├── data-ml/                     # Python + pandas + Jupyter + BigQuery
│   ├── cli-libraries/               # TS/Python/Rust libraries
│   └── automation-agents/           # Python + Playwright + Celery + Anthropic SDK
├── Courses/         # Visione per corso/livello
├── Data/            # Export CSV originali (Notion)
└── CLAUDE.md        # Questo file
```

## Navigazione rapida

- Esplora per **concetto** → `Topics/`
- Esplora per **corso** → `Courses/`
- Dati grezzi → `Data/`

Ogni cartella ha un `index.md` come landing page e un `.nav.yml` per l'ordine di navigazione.

## Contenuti chiave per area

| Area | File di partenza |
|------|-----------------|
| Fondamenti LLM | `Topics/Foundations/Come funzionano i Large Language Model.md` |
| Context Window | `Topics/Foundations/Context Window e Token.md` |
| Prompting | `Topics/Prompting/Anatomia di un prompt efficace.md` |
| Messages API | `Topics/API-Tools/Claude API/Messages API - struttura e parametri.md` |
| Tool Use | `Topics/API-Tools/Claude API/Tool Use (Function Calling).md` |
| Prompt Caching | `Topics/API-Tools/Claude API/Prompt Caching.md` |
| Agentic Loop | `Topics/Agents-MCP/Agent Patterns/Agentic loop e autonomia.md` |
| MCP Architettura | `Topics/Agents-MCP/MCP Core/Model Context Protocol - architettura.md` |
| Claude Code | `Topics/Claude Code/Architettura di Claude Code.md` |
| Decision Frameworks (routing operativo) | `Topics/Decision-Frameworks/index.md` |
| Workflows real-world (playbook end-to-end) | `Topics/Workflows/index.md` |
| Stack Catalog per contesto dev | `Topics/Stacks-Catalog.md` |
| Starter Templates clonabili | `Starter-Templates/README.md` |
| Ethics/Safety | `Topics/Ethics-Safety/Responsible use e bias.md` |

## Per Claude come Advisor

Quando l'utente usa questa KB per "vibe coding" su un nuovo progetto:

1. **Identifica il contesto** (Web/Data/CLI/Automation) → consulta `Topics/Stacks-Catalog.md`
2. **Per il task specifico** → `Topics/Decision-Frameworks/02-task-solution-lookup.md`
3. **Per un workflow end-to-end** → `Topics/Workflows/`
4. **Per setupare il progetto** → `Starter-Templates/<contesto>/`
5. **Per evitare errori comuni** → `Topics/Decision-Frameworks/09-anti-patterns-catalog.md` + `Topics/Workflows/11-anti-patterns-realworld.md`

## Come usare questa KB

- Per trovare un argomento specifico: cerca nei file `index.md` della cartella Topic rilevante
- Per il percorso di apprendimento suggerito: vedi `Topics/index.md`
- Tutte le note sono in italiano
- I CSV in `Data/` contengono metadati strutturati sulle lezioni
