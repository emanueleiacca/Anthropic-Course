---
title: Claude Code Avanzato
tags: [claude-code, configuration, hooks, skills, subagents]
last_updated: 2026-05-14
---

# Claude Code Avanzato

Configurazione approfondita, hooks, custom skills, sub-agents, settings.

## Hooks Lifecycle

Esecuzione deterministica dell'harness in punti specifici. Eventi:

- **PreToolUse**, **PostToolUse**: attorno alle tool execution
- **UserPromptSubmit**: prima che Claude veda il prompt
- **SessionStart**, **SessionEnd**: lifecycle sessione
- **Stop**, **SubagentStop**: arresto agent
- **Notification**: push desktop
- **Compaction**: pre/post compaction
- **FileChanged**, **CwdChanged**: filesystem events

Tipi handler: `command`, `http`, `mcp_tool`, `prompt`, `agent`

Exit codes: `0` success, `2` block (denial), altro warning

## Custom Skills

`.claude/skills/<name>/SKILL.md` con Progressive Disclosure:
- **Level 1**: Frontmatter (sempre) ~100 token
- **Level 2**: Body (on-invoke) <5K token
- **Level 3**: File allegati (on-demand)

Frontmatter chiave:
- `description`: trigger key per discovery
- `disable-model-invocation`: solo user
- `user-invocable: false`: solo Claude
- `allowed-tools`: pre-approva
- `paths`: glob attivazione condizionale
- `context: fork`: esegui in subagent

String substitution: `$ARGUMENTS`, `${CLAUDE_SESSION_ID}`, `${CLAUDE_SKILL_DIR}`

Dynamic context: `` !`command` `` esegue shell prima che Claude veda

## settings.json / settings.local.json

Gerarchia (alta→bassa): managed > CLI args > `.claude/settings.local.json` > `.claude/settings.json` > `~/.claude/settings.json`

Configurazioni principali:
- `model`: override default
- `effortLevel`: low|medium|high|xhigh|max
- `permissions`: allow/ask/deny rules con pattern matching
- `defaultMode`: default|acceptEdits|plan|auto|dontAsk|bypassPermissions
- `env`: inject var di progetto
- `enabledMcpjsonServers`: MCP scope
- `skillOverrides`: visibility control

Permission rule syntax: `Tool` | `Tool(pattern)`  
Es: `Bash(npm run *)`, `Read(./.env)`, `WebFetch(domain:example.com)`

## Sub-agents

`.claude/agents/<name>.md` con frontmatter:
- `tools`: lista tool disponibili
- `model`: override
- `description`: trigger per auto-delegation

Auto-delegation basata su description + contesto

Tool set tipici: read-only (Review), research (+ WebFetch), writers (+ Edit/Write/Bash)

Built-in: `Explore` (ricerca), `Plan` (pianificazione), `general-purpose`

## CLAUDE.md & Memory

**Gerarchia**: managed → user (`~/.claude/CLAUDE.md`) → project (`./.CLAUDE.md`) → local (`./.claude/CLAUDE.md`)

**Subdirectory CLAUDE.md**: Caricate on-demand quando Claude legge file in quella dir

**`.claude/rules/<topic>.md`**: Modular, può avere `paths:` glob frontmatter

**Auto memory**: `~/.claude/projects/<project>/memory/MEMORY.md` (prime 200 righe / 25KB loaded)

**Imports**: `@path/to/file.md` lazy recursive (max 5 hops)

**HTML comments**: `<!-- -->` strippati prima di inject (note per maintainer gratis)

Survival over compaction: project-root CLAUDE.md re-iniettato; nested NO

## Headless Mode & CLI

`claude -p "<prompt>"` per one-shot non-interactive

Opzioni:
- `--output-format json|text|stream-json`
- `--max-turns 10`
- `--model claude-opus-4-7`
- `--allowedTools "Read,Edit,Bash"`

Env: `ANTHROPIC_API_KEY`, `CLAUDE_CODE_USE_BEDROCK=1`, ecc.

GitHub Actions: `anthropics/claude-code-action@v1`

## IDE Integration

**VSCode**: Chat panel grafico, diff nativo, checkpoint undo, @-mention file, `@terminal:name`

**JetBrains**: `Cmd+Esc`/`Ctrl+Esc` launch, diff viewer IDE, file ref con `@src/auth.ts#L1-99`, diagnostic auto-shared

**CLI da IDE terminal**: `/ide` connette session al IDE attivo

**Web (claude.ai/code)**: Sandbox ephemeral, session-bound, hook SessionStart utile per setup

## Vedi Anche

- [[../API-Tools/Skills/]]
- [[../Agents-MCP/Production/Agent-Patterns-Production]]
- [[../Prompting/Advanced/Extended-Thinking]]
