---
title: Claude Skills - Panoramica del Sistema
tags: [skills, api, claude-code, ecosystem]
last_updated: 2026-05-14
---

# Claude Skills: Panoramica del Sistema

**TL;DR**: Le Skills sono cartelle filesystem (con `SKILL.md` + opzionali script/reference) che estendono Claude con expertise di dominio, caricate via progressive disclosure. Open standard dal 18 dicembre 2025 (adottato anche da OpenAI Codex, Cursor, GitHub Copilot, Gemini CLI).

## Quando Usarlo

- Hai procedure ripetitive che incolli ogni volta nel prompt (checklist, convenzioni, workflow multi-step)
- Vuoi specializzare Claude su un dominio (BigQuery schemas, internal API conventions, document processing)
- Una sezione di `CLAUDE.md` è cresciuta da fatto a procedura → diventa skill
- Vuoi distribuire capabilities riutilizzabili a un team

## Quando NON Usarlo / Limiti

- Non sostituiscono MCP: una skill NON può fare API calls o accedere a sistemi esterni autonomamente (solo istruzioni + script)
- Non sostituiscono prompts one-off (overhead di setup non giustificato per task unici)
- Su Claude API: nessun network access, nessuna installazione runtime di package
- Custom skills NON si sincronizzano cross-surface (API ≠ claude.ai ≠ Claude Code)

## Concetti Chiave

- Tre superfici: Claude Code (filesystem-based), Claude API (upload via `/v1/skills`, gira in code execution container), claude.ai (zip upload via Settings)
- Pre-built skills ufficiali: `pdf`, `docx`, `xlsx`, `pptx` (+ open-source `claude-api`)
- Skills sono onboarding manual per un nuovo team member, non magic
- Le 4 skill ufficiali per documenti sono source-available, non MIT
- Open standard pubblico su `agentskills.io` (spec) e `github.com/anthropics/skills` (esempi)

## Pattern & Anti-pattern

**Pattern OK**:
- Una skill = una capability ben definita con trigger chiari
- Test sempre con Haiku/Sonnet/Opus prima di deployare (effectiveness varia)

**Anti-pattern**:
- Skill generiche come `helper`, `utils`, `tools` (Claude non sa quando invocarle)
- Usare skill da fonti untrusted senza audit (possono esfiltrare dati via tool misuse)

## Cross-link

- Progressive Disclosure
- SKILL.md Format
- MCP vs Skills
- Custom Skills Authoring
- Skills nell'API

## Fonti

- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
- https://code.claude.com/docs/en/skills
- https://agentskills.io/specification
- https://github.com/anthropics/skills
