---
title: Custom Skills - Authoring Best Practices
tags: [skills, development, eval-driven, patterns]
last_updated: 2026-05-14
---

# Custom Skills: Authoring Best Practices

**TL;DR**: Scrivere una buona skill = evaluation-driven development con due Claude (Claude A scrive/refina, Claude B testa) + descrizione specifica + concisione (assumi che Claude è smart) + degrees of freedom appropriati al rischio.

## Evaluation-Driven Development

1. Identifica gap senza skill (lo spieghi a Claude più di 2-3 volte)
2. Crea 3 eval scenarios
3. Baseline performance
4. Scrivi minimal SKILL.md
5. Itera vs baseline

## Concise Principle

Ogni token compete con conversation history; chiediti "Claude needs this or already knows it?"

## Degrees of Freedom

- **High freedom** (text instructions): multiple approcci validi, decisioni context-dependent
- **Medium** (pseudocode/template): pattern preferito ma variazione OK
- **Low** (script specifici, no params): operazioni fragili, sequenza critica

## Test Cross-Model

Haiku (più guidance needed), Sonnet, Opus (no over-explanation)

## Esempio Minimo

```markdown
---
name: bigquery-analytics
description: Run BigQuery analytics queries with project conventions (exclude test accounts, use UTC timestamps). Use when user asks about metrics, revenue, sales pipeline, or BigQuery tables.
---

## Quick start
1. Identify dataset: finance | sales | product | marketing
2. Read appropriate schema: `reference/{dataset}.md`
3. MUST filter out test accounts: `WHERE account_type != 'test'`
4. Use UTC timestamps

## Available datasets
- Finance metrics → [reference/finance.md](reference/finance.md)
- Sales pipeline → [reference/sales.md](reference/sales.md)
```

## Pattern & Anti-pattern

**Pattern OK**:
- Description in terza persona con keyword triggers
- Workflow con checklist copyable da Claude per task multi-step
- Feedback loop: run validator → fix → repeat

**Anti-pattern**:
- Offrire troppe opzioni
- Nesting reference > 1 livello
- Date specifiche che invecchiano

## Fonti

- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf
