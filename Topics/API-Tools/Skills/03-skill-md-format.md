---
title: SKILL.md - Struttura e Frontmatter
tags: [skills, format, configuration]
last_updated: 2026-05-14
---

# SKILL.md: Struttura e Frontmatter

**TL;DR**: `SKILL.md` è un Markdown con YAML frontmatter (`name`, `description` obbligatori) + corpo istruzioni. Su Claude Code ha campi extra (`allowed-tools`, `disable-model-invocation`, `paths`, `context: fork`, `hooks`) che non esistono nell'API.

## Frontmatter Obbligatorio

- **`name`**: ≤ 64 char, solo `[a-z0-9-]`, no parole riservate (`anthropic`, `claude`)
- **`description`**: ≤ 1024 char (API) / troncato a 1536 char combinato con `when_to_use` (Claude Code). Terza persona: "Processes Excel files…", NON "I can help you…"

## Campi Claude Code (non API)

- `disable-model-invocation`: solo user può invocare
- `user-invocable: false`: solo Claude, non appare nel menu
- `allowed-tools`: pre-approva tool senza prompt
- `paths`: glob; skill attiva solo per file matching
- `context: fork`: esegui in subagent
- `agent`: quale subagent type
- `model`/`effort`
- `hooks`, `argument-hint`, `arguments`

## String Substitutions

- `$ARGUMENTS`, `$0`/`$1` (posizionali)
- `$name` (con `arguments:` frontmatter)
- `${CLAUDE_SESSION_ID}`, `${CLAUDE_SKILL_DIR}`, `${CLAUDE_EFFORT}`
- `` !`command` ``: esecuzione shell **prima** che Claude veda il content

## Esempio Minimo

```yaml
---
name: commit
description: Stage and commit changes following project conventions. Use when user asks to commit, save changes, or create a git commit.
disable-model-invocation: true
allowed-tools: Bash(git add *) Bash(git commit *) Bash(git status *)
---

## Current state
!`git status --short`
!`git diff --staged`

## Instructions
Commit $ARGUMENTS following Conventional Commits format.
```

## Pattern & Anti-pattern

**Pattern OK**:
- Description: cosa fa + quando usarla + keyword triggers
- Forward slashes nei path (`scripts/helper.py`), mai backslash

**Anti-pattern**:
- Descrizioni vaghe: "Helps with documents"
- Prima persona: "I help you process…"
- Timestamp/info dinamica ("Before August 2025…")

## Fonti

- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- https://code.claude.com/docs/en/skills
