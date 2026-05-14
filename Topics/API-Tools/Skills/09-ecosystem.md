---
title: Skill Ecosystem - Ufficiali, Community, Marketplace
tags: [skills, community, ecosystem, discovery]
last_updated: 2026-05-14
---

# Skill Ecosystem: Skill Ufficiali, Community, Marketplace

**TL;DR**: Anthropic mantiene 4 pre-built (`pdf`, `docx`, `xlsx`, `pptx`) + open-source `claude-api`. Community esplosa: `obra/superpowers` (20+ skill TDD/debugging), aggregator come `travisvn/awesome-claude-skills`, marketplace via `/plugin` command (claudemarketplaces.com, tonsofskills.com con 2810+ skill).

## Pre-built Anthropic

- **Document**: `pdf`, `docx`, `pptx`, `xlsx`
- **Creative**: `algorithmic-art`, `canvas-design`, `slack-gif-creator`
- **Dev**: `frontend-design`, `web-artifacts-builder`, `mcp-builder`
- **Bundled**: `/simplify`, `/debug`, `/batch`, `/loop`, `/claude-api`, `/init`, `/review`, `/security-review`

## Community Notevoli

- `obra/superpowers`: framework TDD-driven (test-driven-development, systematic-debugging, brainstorming, etc.)
- `Hacker0x01/claude-power-user`: HackerOne skill library
- Trail of Bits: security skills (static analysis, code audit)
- Notion Skills: partner ufficiale

## Marketplace

- Anthropic marketplace (default)
- Community: `claudemarketplaces.com`, `tonsofskills.com` (2810 skill)
- Install: `/plugin install <name>@<marketplace>`

## Open Standard Adoption

Dal 18 dicembre 2025 SKILL.md adottato da:
- OpenAI Codex CLI
- Cursor
- GitHub Copilot (via VS Code)
- Gemini CLI
- Microsoft, Atlassian, Figma

## Install Esempio

```bash
# In Claude Code
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace

# Ora hai: /brainstorm, /write-plan, /execute-plan,
# + auto-trigger test-driven-development, systematic-debugging
```

## Pattern & Anti-pattern

**Pattern OK**:
- Start con bundled skill prima di scrivere custom
- Audit script bundled: cerca `curl`, `wget`, network call, file ops

**Anti-pattern**:
- Installare plugin da marketplace untrusted in repo con secret
- Skill che hanno external URL dependencies senza checksum

## Fonti

- https://github.com/anthropics/skills
- https://github.com/obra/superpowers
- https://github.com/travisvn/awesome-claude-skills
- https://claudemarketplaces.com/
