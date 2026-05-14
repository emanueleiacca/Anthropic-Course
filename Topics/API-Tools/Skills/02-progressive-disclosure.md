---
title: Progressive Disclosure - Architettura a Tre Livelli
tags: [skills, context-window, token-efficiency]
last_updated: 2026-05-14
---

# Progressive Disclosure: Architettura a Tre Livelli

**TL;DR**: Le skill caricano contenuto in tre stadi (metadata → SKILL.md body → file bundled) così che 20-50+ skill possano coesistere consumando ~30-50 token di startup ciascuna. È il design principle che rende le skill scalabili.

## Quando Usarlo

- Sempre, è il modello mentale di default per progettare una skill
- Quando il contenuto supera 500 righe → splittare in file separati referenziati da `SKILL.md`
- Per skill con domini multipli (es. BigQuery con finance/sales/product schemas separati)

## Quando NON Usarlo / Limiti

- Riferimenti nested oltre 1 livello: Claude potrebbe fare partial read (`head -100`) e perdere informazioni
- Se il contenuto bundled non viene mai letto → segnala male nelle istruzioni o è superfluo
- Una volta che `SKILL.md` è caricato resta in context per tutta la sessione (re-attaccato dopo auto-compaction con budget 25k token combinato)

## Concetti Chiave

**Level 1 (sempre caricato)**: YAML frontmatter (`name`, `description`) — ~100 token/skill nel system prompt

**Level 2 (on trigger)**: corpo di `SKILL.md` — sotto i 5k token consigliati, max 500 righe

**Level 3 (on demand)**: file bundled letti via bash, script eseguiti senza caricare il codice

**Script execution**: solo l'output consuma token, il codice no → preferire script a generazione runtime

**Budget skill listing scala**: all'1% del context window (configurabile via `skillListingBudgetFraction`)

## Esempio Minimo

```
pdf-skill/
├── SKILL.md          # Overview + quick start
├── FORMS.md          # Loaded solo se serve form-filling
├── REFERENCE.md      # API reference dettagliata
└── scripts/
    └── fill_form.py  # Eseguito via bash, codice non in context
```

## Pattern & Anti-pattern

**Pattern OK**:
- Reference files one-level-deep da SKILL.md (mai catene tipo SKILL→A→B→C)
- TOC in cima a file > 100 righe (Claude può fare partial preview e perdere scope)

**Anti-pattern**:
- Tutto in un unico SKILL.md gigante (> 500 righe) — costo recurring per ogni turn
- Spiegare cose che Claude già sa ("Un PDF è un formato che contiene...")

## Cross-link

- SKILL.md Format
- Custom Skills Authoring
- Context Window
- Token Budget

## Fonti

- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
