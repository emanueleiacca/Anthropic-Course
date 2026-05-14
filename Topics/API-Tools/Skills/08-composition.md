---
title: Skill Composition - Fork, Hooks, Conditional Activation
tags: [skills, subagents, hooks, advanced-patterns]
last_updated: 2026-05-14
---

# Skill Composition: Subagent Fork, Hooks, Conditional Activation

**TL;DR**: Pattern avanzati: `context: fork` esegue skill in subagent isolato (no pollution del main context); skill possono dichiarare `hooks` per lifecycle events; `paths` glob limita attivazione a file matching; UserPromptSubmit hook può forzare evaluation di skill anche quando auto-trigger fallisce.

## Fork Pattern

Ricerche esplorative, analisi parallele (es. impact analysis con 4 subagent paralleli su technical/org/financial/risk)

## Hooks in Skills

Side effects deterministici (logging, validazione) legati al ciclo della skill

## Paths Glob

Skill specifiche per package in monorepo, o per file types (es. attiva solo su `**/*.tsx`)

## Skill Activation Hook

Quando hai 20+ skill e l'auto-trigger non è affidabile

## Concetti Chiave

**`context: fork`** + `agent: Explore`/`Plan`/custom: skill body diventa prompt del subagent

**Skill+subagent duale**: skill può forkare subagent (skill prompt → subagent), OR subagent può precaricare skill

**`paths` glob**: skill auto-trigger SOLO quando si lavora su file matching

**Skill composition tramite reference**: una skill può linkare un'altra skill nei suoi reference file

## Esempio Minimo (fork research skill)

```yaml
---
name: deep-research
description: Research a topic thoroughly across the codebase
context: fork
agent: Explore
allowed-tools: Glob Grep Read
---

Research $ARGUMENTS thoroughly:
1. Find relevant files using Glob and Grep
2. Read and analyze the code
3. Summarize findings with specific file references

Return a structured report: findings, evidence, open questions.
```

## Pattern & Anti-pattern

**Pattern OK**:
- Skill forkate per ricerche read-only (Explore agent)
- `paths` per skill domain-specific (linting skill solo su `*.py`)

**Anti-pattern**:
- `context: fork` su skill che è solo "convenzioni" senza task
- Activation hook con tono aggressivo

## Fonti

- https://code.claude.com/docs/en/skills
