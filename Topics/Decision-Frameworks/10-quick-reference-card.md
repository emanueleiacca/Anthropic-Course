---
title: Quick Reference Card - Comandi, Config, Snippet
tags: [cheatsheet, reference, commands, config, quick-lookup]
last_updated: 2026-05-14
audience: llm-advisory
---

# Quick Reference Card

Cheatsheet di consultazione rapida: comandi piu usati, snippet di configurazione, pattern di uso.

## Comandi Claude Code essenziali

### Modalita interattiva

```bash
claude                              # avvia REPL interattivo nel cwd
claude --model opus                 # forza modello
claude --resume                     # riprendi ultima session
claude /init                        # crea CLAUDE.md per il progetto
claude /memory                      # mostra memory loaded
claude /skills                      # lista skills disponibili
claude /mcp                         # lista server MCP attivi
claude /hooks                       # mostra hooks attivi
claude /agents                      # mostra subagent definiti
```

### Modalita headless (script / CI)

```bash
claude -p "summarize repo"                    # one-shot, output testo
claude -p "..." --output-format json          # output strutturato
claude -p "..." --output-format stream-json   # streaming JSON
claude -p "..." --max-turns 5                 # limita iterazioni
claude -p "..." --allowedTools "Read,Edit"    # whitelist tools
claude -p "..." --skill code-reviewer         # invoca skill specifica
claude -p "..." --agent Plan                  # invoca subagent
```

### Sessioni & state

```bash
claude --session-id <uuid>           # ripristina session per ID
claude --list-sessions               # lista sessioni recenti
claude --export-session <id>         # export JSONL
```

## Struttura file `.claude/`

```
.claude/
├── settings.json                # config committed
├── settings.local.json          # config local (gitignored)
├── CLAUDE.md                    # alias project memory (root preferito)
├── skills/
│   └── my-skill/
│       ├── SKILL.md             # frontmatter + body
│       ├── reference.md         # file lazy-loaded
│       └── scripts/run.sh
├── agents/
│   └── code-reviewer.md         # subagent definition
├── hooks/
│   └── pre-commit.sh
└── plugins/                     # plugin bundle install
```

## Snippet: settings.json minimal

```json
{
  "permissions": {
    "allow": [
      "Read(**/*)",
      "Edit(./src/**)",
      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(npm test:*)"
    ],
    "deny": [
      "Bash(rm -rf:*)",
      "Bash(git push --force:*)"
    ]
  },
  "model": "claude-sonnet-4-6",
  "hooks": {
    "PreToolUse": [
      {"matcher": "Bash", "hooks": [{"type": "command", "command": ".claude/hooks/bash-guard.sh"}]}
    ],
    "PostToolUse": [
      {"matcher": "Edit|Write", "hooks": [{"type": "command", "command": "npm run lint --silent"}]}
    ]
  },
  "mcpServers": {
    "github": {"command": "npx", "args": ["@modelcontextprotocol/server-github"], "env": {"GITHUB_TOKEN": "${GITHUB_TOKEN}"}}
  }
}
```

## Snippet: SKILL.md frontmatter

```yaml
---
name: code-reviewer
description: Review code for security, performance, and style issues. Use after implementation, before commit.
allowed-tools:
  - Read
  - Grep
  - GitHub:get_pull_request
  - GitHub:list_commits
paths:
  - "src/**/*.{ts,tsx,py}"
disable-model-invocation: false   # set true per "slash command only"
user-invocable: true
context: fork                      # esegui in subagent fork
---

# Code Reviewer Skill

## When invoked
$ARGUMENTS contains the PR ID or file path to review.

## Workflow
1. Read changed files via Read
2. Fetch PR context: `GitHub:get_pull_request`
3. Check rules in `reference/security-checklist.md`
4. Output findings in markdown table
```

## Snippet: subagent definition (.claude/agents/)

```yaml
---
name: code-reviewer
description: Read-only code review subagent. Invoked via Task tool with PR/file path.
tools:
  - Read
  - Grep
  - Glob
model: claude-sonnet-4-6
---

You are a code review specialist. Focus on:
- Security vulnerabilities (OWASP top 10)
- Performance bottlenecks
- Code style consistency
- Test coverage gaps

Output findings as markdown table with severity (CRITICAL/HIGH/MEDIUM/LOW).
```

## Snippet: hook script

```bash
#!/bin/bash
# .claude/hooks/bash-guard.sh
# Block destructive bash commands.

read -r INPUT
CMD=$(echo "$INPUT" | jq -r '.tool_input.command')

if echo "$CMD" | grep -qE '(rm -rf|git push --force|drop database)'; then
  echo "Blocked destructive command: $CMD" >&2
  exit 2  # exit 2 = block tool call
fi
exit 0
```

## Snippet: MCP server (FastMCP Python)

```python
from fastmcp import FastMCP

mcp = FastMCP("my-server")

@mcp.tool()
def get_user(user_id: str) -> dict:
    """Fetch user by ID from internal CRM."""
    return crm_client.get(user_id)

if __name__ == "__main__":
    mcp.run(transport="stdio")
```

Registra in `settings.json`:
```json
"mcpServers": {
  "my-server": {"command": "python", "args": ["server.py"]}
}
```

## Anthropic API quick patterns

### Basic call

```python
from anthropic import Anthropic
client = Anthropic()

msg = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello"}]
)
```

### Prompt caching

```python
msg = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    system=[
        {"type": "text", "text": LONG_SYSTEM, "cache_control": {"type": "ephemeral"}}
    ],
    messages=[...]
)
```

### Extended thinking

```python
msg = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=4096,
    thinking={"type": "enabled", "budget_tokens": 16000},
    messages=[...]
)
```

### Tool use

```python
msg = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    tools=[{
        "name": "get_weather",
        "description": "Get current weather",
        "input_schema": {"type": "object", "properties": {"city": {"type": "string"}}, "required": ["city"]}
    }],
    messages=[{"role": "user", "content": "Weather in Rome?"}]
)
```

### Batch API

```python
batch = client.messages.batches.create(
    requests=[
        {"custom_id": "req-1", "params": {"model": "claude-sonnet-4-6", "max_tokens": 100, "messages": [...]}}
    ]
)
```

## CLI patterns ricorrenti

### Code review via headless

```bash
claude -p "Review the diff and list issues" \
  --skill code-reviewer \
  --allowedTools "Read,Grep" \
  --output-format json | jq .result
```

### Daily standup automation

```bash
claude -p "Summarize yesterday's commits and create standup" \
  --mcp-config .claude/mcp.json \
  --skill standup-writer
```

### CI gate

```bash
claude -p "Verify migration safety" \
  --output-format json \
  --max-turns 3 > review.json
EXIT_CODE=$(jq -r '.exit_code' review.json)
exit "$EXIT_CODE"
```

## Pricing quick ref (Maggio 2026)

| Model | Input / Output (per 1M tok) | Cache write 5m | Cache read 5m |
|-------|------------------------------|----------------|---------------|
| Opus 4.7 | $15 / $75 | $18.75 | $1.50 |
| Sonnet 4.6 | $3 / $15 | $3.75 | $0.30 |
| Haiku 4.5 | $0.80 / $4 | $1.00 | $0.08 |
| Mythos Preview | $5 / $25 | $6.25 | $0.50 |

Batch API: -50% su input e output.
Cache write 1h: 2x base. Cache read 1h: 0.1x base.

## Common environment variables

```bash
ANTHROPIC_API_KEY=sk-ant-...
CLAUDE_PROJECT_DIR=/path/to/project       # autoset da Claude Code
CLAUDE_SESSION_ID=<uuid>                  # autoset
ANTHROPIC_LOG=debug                        # verbose SDK logging
ANTHROPIC_BASE_URL=...                     # custom endpoint (Bedrock/Vertex)
```

## Diagnostica rapida

```bash
claude /doctor                    # health check setup
claude --debug                    # verbose logging
claude /clear                     # reset context corrente
claude /compact                   # compatta history
claude --version                  # version check
```

## Plugin marketplace (2026)

```bash
claude /plugin search <keyword>
claude /plugin install <name>
claude /plugin list
claude /plugin update
```

## Riferimenti

- Claude Code reference (claude.com/code/docs)
- API reference (docs.claude.com)
- Skills cookbook (github.com/anthropics/skills)
- Cookbook patterns (github.com/anthropics/anthropic-cookbook)
- Vedi anche: [[../Claude Code/Claude-Code-Advanced.md]] e [[../API-Tools/Skills/index.md]]
