---
title: Skills in Claude Code - Filesystem-based & Live Reload
tags: [skills, claude-code, configuration, live-reload]
last_updated: 2026-05-14
---

# Skills in Claude Code: Filesystem-based & Live Reload

**TL;DR**: In Claude Code le skill vivono nel filesystem (`~/.claude/skills/`, `.claude/skills/`, plugin), supportano live change detection, full network access, e features esclusive: `paths` glob, `context: fork`, `allowed-tools`, hooks per-skill.

## Quando Usarlo

- Workflow ripetitivi che pasti nella chat (`/commit`, `/deploy`, `/review-pr`)
- Knowledge base di progetto (API conventions, style guide, schema DB)
- Skill che devono fare API calls / filesystem ops (non possibili via API container)

## Scope & Precedenza

Enterprise > Personal (`~/.claude/skills/`) > Project (`.claude/skills/`) > Plugin (namespaced `plugin:skill`)

## Live Reload

Aggiungere/edit/rimuovere skill in dir esistenti è instant; nuove top-level dir richiedono restart

## Lifecycle

Dopo invoke, content resta in context tutta la sessione; auto-compaction ri-attacca le ultime invocazioni (5K token cap per skill, 25K totale)

## Esempio Minimo

```yaml
---
name: summarize-changes
description: Summarizes uncommitted changes and flags risks. Use when user asks what changed, wants commit message, or asks to review diff.
---

## Current changes
!`git diff HEAD`

## Instructions
Summarize in 2-3 bullets, then list risks: missing error handling,
hardcoded values, tests that need updating.
```

## Pattern & Anti-pattern

**Pattern OK**:
- Skill destructive (`/deploy`, `/commit`) → `disable-model-invocation: true`
- Skill di knowledge passiva (es. `legacy-system-context`) → `user-invocable: false`
- Per monorepo: skill in `packages/frontend/.claude/skills/` caricate solo se lavori in quel package

**Anti-pattern**:
- Mettere segreti in skill committate (vengono trustate dopo workspace trust dialog)
- Confondere `disable-model-invocation` (blocca Claude) con `user-invocable: false` (blocca utente)

## Fonti

- https://code.claude.com/docs/en/skills
