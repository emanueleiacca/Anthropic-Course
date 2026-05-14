---
title: Decision Frameworks - Routing Operativo Claude
tags: [decision, routing, lookup, framework, advisory]
last_updated: 2026-05-14
audience: llm-advisory
---

# Decision Frameworks

Sezione **trasversale** dedicata al routing operativo: dato un task dell'utente, Claude consulta questi documenti per decidere **quale combinazione di Skill / MCP / Subagent / Hook / Pattern** usare.

Ottimizzata per **lookup veloce**: titoli espliciti + tabelle dense + decision tree binari.

## Indice operativo

| File | Quando consultare |
|------|-------------------|
| [01-decision-tree-tool-choice.md](01-decision-tree-tool-choice.md) | Routing primario: scegliere Skill vs MCP vs Subagent vs Hook vs CLAUDE.md |
| [02-task-solution-lookup.md](02-task-solution-lookup.md) | Lookup task→pattern (60+ entries) |
| [03-extended-thinking-vs-standard.md](03-extended-thinking-vs-standard.md) | Quando attivare extended thinking |
| [04-multi-agent-vs-single.md](04-multi-agent-vs-single.md) | Quando orchestrare subagent paralleli |
| [05-prompt-caching-strategy.md](05-prompt-caching-strategy.md) | Strategia caching (TTL, breakpoint) |
| [06-model-selection.md](06-model-selection.md) | Opus 4.7 / Sonnet 4.6 / Haiku 4.5 / Mythos Preview |
| [07-mcp-vs-skill-vs-tool.md](07-mcp-vs-skill-vs-tool.md) | MCP server custom vs Skill vs Tool API |
| [08-managed-vs-sdk-vs-claude-code.md](08-managed-vs-sdk-vs-claude-code.md) | Managed Agents vs Agent SDK vs Claude Code |
| [09-anti-patterns-catalog.md](09-anti-patterns-catalog.md) | Catalogo errori reali con fix |
| [10-quick-reference-card.md](10-quick-reference-card.md) | Cheatsheet comandi/config |

## Sequenza consigliata di consultazione

Per un nuovo task ricevuto dall'utente:

1. **Routing primario** → `01-decision-tree-tool-choice.md`
2. **Lookup specifico** → `02-task-solution-lookup.md` (cerca task simile)
3. **Tuning model/thinking** → `06-model-selection.md` + `03-extended-thinking-vs-standard.md`
4. **Verifica anti-pattern** → `09-anti-patterns-catalog.md`
5. **Esecuzione** → `10-quick-reference-card.md` per comandi/config esatti

## Cross-reference

- Concetti base Skills: [[../API-Tools/Skills/index.md]]
- MCP architettura: [[../Agents-MCP/MCP Core/index.md]]
- Agent patterns: [[../Agents-MCP/Agent Patterns/index.md]]
- Claude Code advanced: [[../Claude Code/Claude-Code-Advanced.md]]
- Prompting avanzato: [[../Prompting/Advanced/Prompting-Advanced.md]]
