---
title: Playbook - Bootstrap nuovo progetto da zero
tags: [bootstrap, setup, CLAUDE.md, MCP, skills, subagent, workflow]
last_updated: 2026-05-14
audience: llm-advisory
---

# Bootstrap nuovo progetto da zero con Claude Code

### Playbook: Bootstrap new project

**TL;DR**: Setup minimo opinionato di un nuovo progetto in modo che Claude Code abbia immediato context completo. Include `CLAUDE.md` lean, MCP stack mirato per contesto, custom skill iniziali e hook pre-commit. Da fare PRIMA di chiedere a Claude di scrivere codice produttivo.

**Contesti applicabili**: Web | Data | CLI | Automation (varianti per ognuno)

**Pre-requisiti**:
- Claude Code v2.1+ installato (`claude --version`)
- Repo git inizializzato con almeno `main` branch
- `~/.claude/settings.json` con `ANTHROPIC_API_KEY` o subscription auth

**Workflow step-by-step**:

1. **Crea struttura base in repo**:
   ```bash
   mkdir -p .claude/{agents,skills,commands,hooks}
   touch CLAUDE.md .claude/settings.json .mcp.json
   ```

2. **Scrivi `CLAUDE.md` lean (target: <300 righe, <5KB)**. Il contenuto va focalizzato su:
   - Stack tecnologico (3-5 righe)
   - Comandi essenziali (test, lint, build, dev)
   - Convenzioni hard (es. "uv per Python, no pip diretto")
   - Glossario domain-specific (5-10 termini)
   - **NIENTE @-mention di doc enormi** (Scott Spence, Trail of Bits insistono su questo)

3. **Configura MCP stack mirato** in `.mcp.json` (max 3-5 server per progetto):
   - **Sempre**: Context7 (doc), Serena o filesystem-mcp (code navigation)
   - **Web**: Vercel plugin (se hosting Vercel), Playwright MCP, GitHub MCP
   - **Data**: BigQuery / Snowflake CLI (no MCP - bq CLI è più efficiente), Filesystem
   - **CLI**: GitHub MCP, Context7
   - **Automation**: Playwright, GitHub, custom domain MCP

4. **Crea sub-agent iniziali in `.claude/agents/`**:
   - `reviewer.md` - code review specialista
   - `planner.md` - design doc + implementation plan
   - `tester.md` - test generation TDD

5. **Aggiungi hook pre-commit minimali** in `.claude/settings.json`:
   - PreToolUse Bash: blocca `rm -rf`, `git push origin main`
   - PostToolUse Edit/Write: trigger formatter (ruff, prettier, gofmt)

6. **Verifica con `claude` interattivo**: chiedi "what is this project?" e valida che la risposta sia accurata in 1-2 frasi.

7. **Commit baseline**: `git add .claude CLAUDE.md .mcp.json && git commit -m "chore: claude code bootstrap"`

**Setup files richiesti**:

```markdown
<!-- CLAUDE.md (Web variant - Next.js) -->
# Project XYZ

Next.js 15 SaaS app. App Router, Server Components, TypeScript strict, Postgres (Drizzle), Redis.

## Commands
- `pnpm dev` - dev server (port 3000)
- `pnpm test` - vitest + RTL
- `pnpm test:e2e` - playwright
- `pnpm lint` - biome check
- `pnpm db:push` - drizzle migrate dev

## Conventions
- Server Components default; Client Components solo con marker esplicito
- Drizzle queries in `src/db/queries/*.ts`, mai inline in route
- Tutti i fetch hanno `try/catch` + sentry capture
- NO `any` in TypeScript; prefer `unknown` + narrow
- Test colocali: `feature.ts` + `feature.test.ts`

## Glossary
- Workspace: tenant level (un user puo avere piu workspace)
- Run: singola esecuzione di una pipeline (UUID v7)
```

```yaml
# .claude/agents/reviewer.md
---
name: reviewer
description: Reviews staged changes for bugs, CLAUDE.md compliance, security. Use proactively before commits.
model: opus
tools: Read, Grep, Glob, Bash
---

You review code changes. Output HIGH SIGNAL issues only:
- Syntax/type errors
- Logic bugs (off-by-one, null deref, race conditions)
- Security (SQLi, XSS, secrets in code, weak crypto)
- CLAUDE.md violations (cite specific rule)

DO NOT flag: style, subjective preferences, "potential" issues without evidence.
Output format: `path:line - SEVERITY: description`
```

```json
// .claude/settings.json (estratto)
{
  "permissions": {
    "deny": [
      "Read(./.env*)",
      "Read(~/.ssh/**)",
      "Bash(rm -rf*)",
      "Bash(git push origin main*)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [{
          "type": "command",
          "command": "if [[ \"$CLAUDE_TOOL_INPUT_FILE_PATH\" == *.ts || \"$CLAUDE_TOOL_INPUT_FILE_PATH\" == *.tsx ]]; then pnpm exec biome check --apply \"$CLAUDE_TOOL_INPUT_FILE_PATH\"; fi"
        }]
      }
    ]
  }
}
```

**Varianti per contesto**:

| Contesto | MCP stack | Hook chiave | Sub-agent iniziali |
|----------|-----------|-------------|---------------------|
| Web Next.js | Vercel + Playwright + GitHub + Context7 | format on write (biome/prettier) | reviewer, e2e-tester, db-migrator |
| Data/ML | Filesystem + Jupyter MCP, **bq CLI** (no MCP) | nbstripout pre-commit, ruff on .py | data-validator, notebook-cleaner |
| CLI/lib | GitHub + Context7 + Serena | clippy/cargo deny on Rust | doc-writer, release-notes |
| Automation | Playwright + GitHub + sentry-mcp | log injection on tool call | scraper-tester, retry-handler |

**Esempio di sessione tipo**:

```
User: Bootstrap questo repo Next.js per Claude Code production
Claude: [usa Glob per scoprire stack]
        [legge package.json, tsconfig, drizzle.config]
        Stack rilevato: Next 15.2 App Router, Drizzle, Redis, Playwright.
        Creo:
        1. CLAUDE.md (240 righe) con stack/cmd/conv/glossary
        2. .mcp.json con: context7, playwright, github, vercel-plugin
        3. .claude/agents/{reviewer,e2e-tester}.md
        4. .claude/settings.json con hook biome PostToolUse + permission deny .env
        5. .claude/commands/dev-loop.md con shortcut pnpm dev + db push
        Procedo?
User: si
[tool calls: Write CLAUDE.md, Write .mcp.json, Write 4 file agents, ...]
```

**Metriche di successo**:
- Prossima sessione: chiedi "explain architecture in 3 sentences" → risposta accurata in <30s senza letture esplorative
- `claude --bare -p "what test framework?"` risponde correttamente in <1s
- Token iniziali contesto: <8K (verifica con `/context`)

**Pitfalls comuni**:
- CLAUDE.md >500 righe → il content si re-inietta su ogni tool call, satura context (issue #29971 anthropics/claude-code). Tieni <5KB.
- Troppi MCP server (10+) → 50K+ token solo nelle definizioni tool. Attiva Tool Search o limita a 3-5.
- `@-mention` di docs nel CLAUDE.md → embed file enormi a ogni run. Usa Context7 MCP invece.
- `enableAllProjectMcpServers: true` con repo external → rischio MCP malevoli. Trail of Bits raccomanda `false` di default.

**Fonti / Reference reali**:
- [Anthropic Best Practices Claude Code](https://www.anthropic.com/engineering/claude-code-best-practices) - explore→plan→code→commit ufficiale
- [Trail of Bits claude-code-config](https://github.com/trailofbits/claude-code-config) - 2000 righe global CLAUDE.md, hook anti rm -rf, permission deny credenziali
- [Vercel next-devtools-mcp CLAUDE.md](https://github.com/vercel/next-devtools-mcp/blob/main/CLAUDE.md) - template ufficiale Next.js
- [Stripe stripe-ios CLAUDE.md](https://github.com/stripe/stripe-ios/blob/master/CLAUDE.md) - real production CLAUDE.md per SDK iOS
- [pydevtools - Configure Claude Code with uv](https://pydevtools.com/handbook/how-to/how-to-configure-claude-code-to-use-uv/) - Python uv hook + CLAUDE.md
- [Scott Spence - Optimising MCP Server Context Usage](https://scottspence.com/posts/optimising-mcp-server-context-usage-in-claude-code) - quanti MCP e perche
