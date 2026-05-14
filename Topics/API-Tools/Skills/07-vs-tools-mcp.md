---
title: Skills vs Tools vs MCP vs Slash Commands
tags: [skills, tools, mcp, architecture, pattern]
last_updated: 2026-05-14
---

# Skills vs Tools vs MCP vs Slash Commands

**TL;DR**: **Tools** = atomi (singola funzione, input→output). **MCP** = plumbing (connette Claude a sistemi esterni stateful). **Skills** = ricette/istruzioni (insegna pattern, non chiama API). **Slash Commands** = mergiati nelle skill da fine 2025 (`disable-model-invocation: true` simula vecchio comportamento).

## Matrice Decisionale

| Use Case | Scelta |
|----------|--------|
| "Genera commit message nel nostro formato" | Skill |
| "Trova le ultime 10 issue Jira" | MCP (Jira) |
| "Esegui code review approfondita su questa PR" | Subagent (con Skill code-review + MCP github) |
| "Calcola somma di due numeri" | Tool API diretto (overkill MCP) |
| "Multi-step debugging che esplora 50 file" | Subagent (context isolation) |

## MCP vs Skill in Combo

Nella skill, riferisci tool MCP con `ServerName:tool_name` fully qualified

```markdown
---
name: triage-bug
description: Triage a GitHub bug report by analyzing issue and recent commits
allowed-tools: GitHub:get_issue GitHub:list_commits
---

## Workflow
1. Fetch issue: use GitHub:get_issue tool with $ARGUMENTS
2. List recent commits: GitHub:list_commits (last 20)
3. Cross-reference to identify likely regression
```

## Plugin Unification (gennaio 2026)

Bundle di skills + MCP + slash commands + subagents + hooks in singolo install

## Pattern & Anti-pattern

**Pattern OK**:
- Skill per "come fare X bene" + MCP per "accedi a Y"
- Tool MCP fully qualified

**Anti-pattern**:
- Mettere credenziali API in skill
- Hardcodare logic in tool quando potrebbe essere skill

## Fonti

- https://devtoolpicks.com/blog/claude-skills-vs-mcp-connectors-vs-plugins-2026
- https://duet.so/guides/agent-skills-101-tools-vs-mcp-vs-skills
