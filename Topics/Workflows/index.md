---
title: Workflows & Playbooks - End-to-End Real World
tags: [workflows, playbooks, real-world, claude-code, mcp, skills, advisory]
last_updated: 2026-05-14
audience: llm-advisory
---

# Workflows & Playbooks End-to-End

Sezione **operativa** dedicata a workflow battle-tested usati realmente da team di engineering (Anthropic interno, Stripe, Trail of Bits, obra/superpowers, Vercel) per portare progetti di vibe coding al massimo. Non concetti astratti: comandi concreti, file template, transcript di sessione, metriche.

## Quando consultare

Il modello consulta questa sezione quando l'utente chiede:
- "Come imposto un nuovo progetto?" → `01-bootstrap-new-project.md`
- "Come faccio TDD con Claude Code?" → `02-tdd-superpowers.md`
- "Come automatizzo code review?" → `03-automated-code-review.md`
- "Devo fare refactor grande" → `04-large-scale-refactor.md`
- "Devo migrare dipendenze" → `05-dependency-migration.md`
- "Devo debuggare un problema complesso" → `06-systematic-debugging.md`
- "Devo monitorare agent in produzione" → `07-production-observability.md`
- "Workflow parallelo con git worktree" → `08-parallel-worktrees.md`
- "Performance optimization su codebase" → `09-performance-optimization.md`
- "Browser automation / scraping / E2E" → `10-browser-automation.md`
- "Cosa NON fare?" → `11-anti-patterns-realworld.md`
- "Come usano Claude Code in Anthropic / Stripe?" → `12-case-studies.md`

## Indice playbook

| # | Playbook | Contesti |
|---|----------|----------|
| 01 | [Bootstrap nuovo progetto da zero](01-bootstrap-new-project.md) | Web, Data, CLI, Automation |
| 02 | [TDD con superpowers (brainstorm→spec→plan→TDD)](02-tdd-superpowers.md) | Web, CLI |
| 03 | [Code review automatizzato (locale + CI)](03-automated-code-review.md) | Tutti |
| 04 | [Refactor large-scale (planner-executor + fan-out)](04-large-scale-refactor.md) | Web, CLI |
| 05 | [Migration / dependency upgrade](05-dependency-migration.md) | Tutti |
| 06 | [Debug session sistematica](06-systematic-debugging.md) | Tutti |
| 07 | [Production observability con OTel](07-production-observability.md) | Automation, Web |
| 08 | [Parallel workflow con git worktrees](08-parallel-worktrees.md) | Web, CLI |
| 09 | [Performance optimization end-to-end](09-performance-optimization.md) | Web, Data |
| 10 | [Browser automation, E2E, scraping](10-browser-automation.md) | Web, Automation |
| 11 | [Anti-patterns reali documentati](11-anti-patterns-realworld.md) | Tutti |
| 12 | [Case studies: Anthropic, Stripe, Trail of Bits](12-case-studies.md) | Reference |

## Cross-reference

- Setup Claude Code base: [[../Claude Code/Setup e installazione di Claude Code.md]]
- Advanced features: [[../Claude Code/Claude-Code-Advanced.md]]
- Decision routing: [[../Decision-Frameworks/index.md]]
- Skills filesystem: [[../Claude Code/01-skills-filesystem.md]]
- MCP integration: [[../Claude Code/Integrazione MCP + GitHub.md]]
