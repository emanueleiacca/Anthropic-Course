---
title: Skills Ecosystem - Guida Completa
tags: [skills, index, reference]
last_updated: 2026-05-14
---

# Skills Ecosystem

Questa sezione raccoglie il reference completo su Claude Skills: come funzionano, come costruirle, quando usarle, e come scoprire skill della community.

## File in questa sezione

- **01-panoramica.md** — Cos'è una skill, 3 superfici (Claude Code / API / claude.ai), open standard
- **02-progressive-disclosure.md** — Architettura a 3 livelli per scalabilità
- **03-skill-md-format.md** — Struttura SKILL.md, frontmatter, substitution
- **04-skills-api.md** — Skills nella Claude API con code execution container
- **01-skills-filesystem.md** — (in Claude Code/) Filesystem-based, live reload, scope hierarchy
- **06-custom-authoring.md** — Scrivere custom skills, eval-driven development
- **07-vs-tools-mcp.md** — Quando usare skills vs tools vs MCP vs slash commands
- **08-composition.md** — Pattern avanzati (fork, hooks, paths glob)
- **09-ecosystem.md** — Skill ufficiali, community (superpowers), marketplace

## Concetti Chiave

- **Progressive disclosure**: metadata (~100 token) + body on-demand + files lazy-loaded
- **Open standard**: dal dic 2025 adottato da Cursor, GitHub Copilot, Gemini CLI, ecc.
- **Tre superfici**: Claude Code (filesystem), API (container), claude.ai (zip)
- **Skill composition**: fork per subagent, hooks per side-effects, paths glob per scoping
- **Ecosystem 2026**: 2810+ skill pubbliche, marketplace ufficiale integrato, plugin bundle

## Quando Usare Skills

✓ Procedure ripetute nel prompt  
✓ Knowledge base di dominio  
✓ Workflow specializzati (deploy, review, commit)  
✗ Azioni riservate (usa MCP)  
✗ Logica di business critica (usa MCP server)  

## Vedi Anche

- [[MCP Core/index.md]]
- [[../Claude API/Tool Use (Function Calling).md]]
- [[../../Claude Code/02-settings.json]]
