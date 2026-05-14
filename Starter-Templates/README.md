# Starter Templates

Configurazioni clonabili per 4 contesti di sviluppo, ottimizzate per Claude Code 2026 con MCP/Skills/Sub-agents/Hooks/Rules pronti.

## Contesti disponibili

| Template | Stack | Focus |
|----------|-------|-------|
| [web-fullstack/](web-fullstack/) | Next.js 15 + React 19 + Postgres + Redis | API design, DB safety, security, UI patterns |
| [data-ml/](data-ml/) | Python + pandas/polars + Jupyter + BigQuery/Snowflake | EDA, model eval, notebook discipline, SQL |
| [cli-libraries/](cli-libraries/) | TypeScript/Python/Rust libraries | API stability, CLI UX, release automation, testing |
| [automation-agents/](automation-agents/) | Python + Playwright + Celery + Anthropic SDK | Scraping ethics, agent safety, retry, observability |

## Come usare

```bash
# 1. Clone il template che corrisponde al tuo contesto
cp -r Starter-Templates/web-fullstack/. /path/to/your/project/

# 2. Sostituisci tutti i <<TODO: ...>> placeholder
grep -rn "<<TODO:" /path/to/your/project/

# 3. Configura env vars richiesti (vedi .env.example dopo creazione)

# 4. Apri Claude Code: il setup viene caricato automaticamente
cd /path/to/your/project/
claude
```

## Cosa contiene ogni template

Ogni cartella ha questa struttura:

```
<context>/
├── CLAUDE.md                    # Memory principale del progetto
├── .mcp.json                    # Stack MCP server scope project
└── .claude/
    ├── settings.json            # Permissions, model, hooks, env
    ├── agents/                  # 3 sub-agents specializzati
    │   ├── <agent-1>.md
    │   ├── <agent-2>.md
    │   └── <agent-3>.md
    ├── skills/                  # 3 custom skills triggered su keyword
    │   ├── <skill-1>/SKILL.md
    │   ├── <skill-2>/SKILL.md
    │   └── <skill-3>/SKILL.md
    ├── hooks/                   # 3 hook script (lifecycle automation)
    │   ├── pre-tool-*-guard.sh
    │   ├── post-edit-format.sh
    │   └── session-start-check.sh
    └── rules/                   # 3 path-scoped rules
        ├── <rule-1>.md
        ├── <rule-2>.md
        └── <rule-3>.md
```

## Personalizzazione

I template hanno placeholder `<<TODO: ...>>` esplici in:
- `CLAUDE.md`: nome progetto, descrizione, dettagli stack-specifici
- `.claude/settings.json`: env vars
- `.mcp.json`: org slug, project ref, credenziali

Quando li sostituisci, considera che gli **hook script richiedono permessi di esecuzione**:

```bash
chmod +x .claude/hooks/*.sh
```

## Vedi anche

- [[../Topics/Claude Code/Claude-Code-Advanced.md]] per il reference dei concetti
- [[../Topics/Decision-Frameworks/]] per scegliere quale template usare
- [[../Topics/Workflows/]] per playbook end-to-end
