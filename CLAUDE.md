# Anthropic Academy Knowledge Base - Guida per Claude

## Cos'è questo repo

Knowledge base in Markdown per lo studio di Anthropic, Claude, sistemi agentici, MCP, prompting, API e Claude Code. Costruita da note esportate e riorganizzata gerarchicamente.

## Struttura

```
.
├── Topics/          # Tassonomia principale per concetto
│   ├── Foundations/
│   ├── Prompting/
│   ├── API-Tools/
│   │   ├── Claude API/
│   │   └── Agent Tooling/
│   ├── Agents-MCP/
│   │   ├── Agent Patterns/
│   │   ├── MCP Core/
│   │   ├── Cowork/
│   │   └── Retrieval/
│   ├── Claude Code/
│   └── Ethics-Safety/
├── Courses/         # Visione per corso/livello
│   ├── L1 Foundations/
│   ├── L2 Workflow/
│   ├── L3 Agentic & MCP/
│   ├── L4 Claude Code/
│   └── Bonus Cloud/
├── Data/            # Export CSV originali (Notion)
│   ├── Lessons Log.csv
│   ├── Topics Index.csv
│   └── ...
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
| Ethics/Safety | `Topics/Ethics-Safety/Responsible use e bias.md` |

## Come usare questa KB

- Per trovare un argomento specifico: cerca nei file `index.md` della cartella Topic rilevante
- Per il percorso di apprendimento suggerito: vedi `Topics/index.md`
- Tutte le note sono in italiano
- I CSV in `Data/` contengono metadati strutturati sulle lezioni
