---
title: Skills nella Claude API - Implementazione Concreta
tags: [skills, api, container, code-execution]
last_updated: 2026-05-14
---

# Skills nella Claude API: Implementazione Concreta

**TL;DR**: Le skill via API girano nel code execution container Anthropic. Si attivano passando `container.skills` con `skill_id` + 3 beta header. Custom skill caricate via `/v1/skills` (workspace-wide).

## Tre Beta Header Obbligatori

```
code-execution-2025-08-25
skills-2025-10-02
files-api-2025-04-14
```

## Quando Usarlo

- Generazione documenti (`pptx`, `xlsx`, `docx`, `pdf`) senza scrivere boilerplate
- Specializzazione di agenti programmatici via custom skills uploadate
- Quando vuoi conoscenza domain-specific condivisa tra membri del workspace

## Limiti

- **No network access** nel container API
- No runtime package installation (solo pre-installati)
- Feature **non eligible per Zero Data Retention (ZDR)**
- Beta only: header obbligatori, può cambiare

## Esempio Minimo

```python
import anthropic
client = anthropic.Anthropic()

response = client.beta.messages.create(
    model="claude-opus-4-7",
    max_tokens=4096,
    betas=["code-execution-2025-08-25", "skills-2025-10-02", "files-api-2025-04-14"],
    container={
        "skills": [
            {"type": "anthropic", "skill_id": "xlsx", "version": "latest"},
            {"type": "custom", "skill_id": "skill_01AbCdEf...", "version": "latest"},
        ]
    },
    messages=[{"role": "user", "content": "Analyze sales data and generate report"}],
    tools=[{"type": "code_execution_20250825", "name": "code_execution"}],
)

# Upload custom skill da directory
from anthropic.lib import files_from_dir
skill = client.beta.skills.create(
    display_title="Financial Analysis",
    files=files_from_dir("./financial_skill/"),
)
```

## Pattern & Anti-pattern

**Pattern OK**:
- Bundle multiple skill correlate in una sola chiamata
- Riuso container per conversazioni multi-turn

**Anti-pattern**:
- Dimenticare un beta header
- Caricare skill che fanno API esterne nell'API container (no network)

## Fonti

- https://platform.claude.com/docs/en/build-with-claude/skills-guide
- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/quickstart
