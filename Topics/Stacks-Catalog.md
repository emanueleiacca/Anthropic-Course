---
title: Stacks Catalog per Contesto Dev
tags: [stacks, mcp, skills, agents, hooks, reference]
last_updated: 2026-05-14
audience: llm-advisory
---

# Stacks Catalog per Contesto Dev

Catalogo curato (battle-tested) di stack consigliati per 4 contesti dev. Per ogni contesto: MCP server, custom skills, sub-agents, hooks, community references, anti-patterns.

## Indice

- [Stack A: Full-stack Web](#stack-a-full-stack-web)
- [Stack B: Data Analysis / ML](#stack-b-data-analysis--ml)
- [Stack C: CLI / Libraries](#stack-c-cli--libraries)
- [Stack D: Automation / Scraping / Agents](#stack-d-automation--scraping--agents)
- [Transversal Patterns](#transversal-patterns)

---

## Stack A: Full-stack Web

**Profile**: Next.js/React + Node/Python + Postgres/Redis

### MCP Stack

| Server | Repo | Scope | Capability | Token cost | Auth |
|--------|------|-------|------------|------------|------|
| github | github/github-mcp-server | user | PR/issue ops, code search | ~6-8k | OAuth/PAT |
| context7 | upstash/context7 | user | Docs version-specific (Next.js, React, Prisma) | ~1.5k | None |
| supabase | supabase-community/supabase-mcp | project | DB ops + RLS-aware + auth | ~8-10k | OAuth (PAT CI) |
| postgres | crystaldba/postgres-mcp | project | Query, schema, EXPLAIN (read-only) | ~3k | Connection string |
| next-devtools | vercel/next-devtools-mcp | project | Build/runtime/type errors live | ~2k | None (local) |
| playwright | microsoft/playwright-mcp | project | E2E test, accessibility tree | ~5k | None |
| sentry | getsentry/sentry-mcp | user | Errori prod in context | ~3k | OAuth |

**Opzionali**: vercel (deploy), convex (fullstack alt), figma (Dev Mode MCP).

**Trade-off**: `supabase` mantiene RLS → preferibile a `postgres` raw quando esiste auth. `postgres` raw in read-only.

### Custom Skills

| Skill | Trigger | Source |
|-------|---------|--------|
| brainstorming | "let's design", "how should we approach" | obra/superpowers |
| test-driven-development | "implement X", "add feature" | obra/superpowers |
| writing-plans | post-brainstorming | obra/superpowers |
| using-git-worktrees | "start new feature branch" | obra/superpowers |
| commit | "commit", "save", "stage" | superpowers/template |
| nextjs-app-router | "create page/route", "server component" | template custom |
| react-component-create | "build component", "new UI" | template custom |
| db-migration | "alter schema", "add column" | template custom |

### Sub-agents

| Agent | Tool set | Model | Use case |
|-------|----------|-------|----------|
| code-reviewer | Read, Grep, Glob | sonnet | After writing/modifying code |
| frontend-developer | Read, Write, Edit, Bash, Grep, Glob | sonnet | React/Next.js implementation |
| backend-developer | Read, Write, Edit, Bash, Grep, Glob | sonnet | API routes, server actions, DB |
| qa-runner | Read, Bash, Grep | haiku | Runs Playwright/vitest, parses output |
| security-auditor | Read, Grep, Glob | sonnet | XSS, SQLi, secrets, auth bypass (read-only) |

### Hooks

| Event | Command | Purpose |
|-------|---------|---------|
| `PostToolUse(Edit\|Write)` `*.{ts,tsx,js,jsx}` | `prettier --write && eslint --fix` | Format + autofix |
| `PostToolUse(Edit\|Write)` `*.py` | `ruff format && ruff check --fix` | Backend Python |
| `PreToolUse(Bash)` `git push` | Block push diretto su main | Branch protection |
| `Stop` | `pnpm test --run` | Verifica green tests |
| `SessionStart` | `git status` + branch info | Audit context iniziale |

### Community References

- **obra/superpowers**: framework canonico brainstorm→plan→TDD→review
- **VoltAgent/awesome-claude-code-subagents** `/categories/01-core-development/`: 100+ subagent
- **wshobson/agents**: orchestrazione multi-agent
- **Hacker0x01/claude-power-user**: HackerOne security-focused skills

### Anti-Stack

- ✗ Github + GitLab + BitBucket MCP contemporaneamente (15-20k token startup)
- ✗ `postgres` raw + `supabase` MCP sullo stesso DB (bypass RLS)
- ✗ Filesystem MCP root-wide (duplica built-in)
- ✗ Playwright MCP per task che Playwright CLI risolve (4x più costoso)
- ✗ `supabase` MCP senza `--project-ref` (PAT scope account-wide)

---

## Stack B: Data Analysis / ML

**Profile**: Python + pandas/polars + Jupyter + BigQuery/Snowflake

### MCP Stack

| Server | Repo | Scope | Capability | Token cost | Auth |
|--------|------|-------|------------|------------|------|
| jupyter | datalayer/jupyter-mcp-server | project | Cell exec, kernel I/O, multimodal output | ~3k | Token Jupyter |
| bigquery-toolbox | googleapis/mcp-toolbox | project | SQL exec, dataset metadata (read-only) | ~4k | gcloud ADC |
| snowflake | Snowflake-Labs/mcp | project | Cortex AI, SQL, object mgmt | ~6k | Key-pair/OAuth |
| context7 | upstash/context7 | user | Docs (pandas, polars, scikit, pytorch) | ~1.5k | None |
| filesystem (scoped) | modelcontextprotocol/servers | project | Read CSV/parquet/json | ~2k | None (path-scoped) |
| github | github/github-mcp-server | user | Notebook + dataset versioning (DVC) | ~6k | OAuth |

**Opzionali**: duckdb (via skill, non MCP), huggingface, weights-and-biases.

**Critical**: per notebook workflow usa Jupyter MCP, **non** `NotebookEdit` built-in.

### Custom Skills

| Skill | Trigger | Source |
|-------|---------|--------|
| duckdb | "query CSV", "analyze parquet" | duckdb/duckdb-skills |
| eda-template | "explore dataset", "EDA" | template custom |
| pandas-best-practices | implicit on .py edit | template custom |
| polars-migration | "convert to polars" | template custom |
| ml-experiment | "train model", "experiment" | template custom |
| notebook-hygiene | implicit on .ipynb | template custom |
| sql-formatter | implicit on .sql edit | community |
| viz-recommender | "plot", "visualize" | template custom |

### Sub-agents

| Agent | Tool set | Model | Use case |
|-------|----------|-------|----------|
| data-scientist | Read, Write, Edit, Bash, Glob, Grep, WebFetch | sonnet | EDA, hypothesis, statistical insights |
| data-engineer | Read, Write, Edit, Bash, Glob, Grep | sonnet | ETL/ELT, warehouse, stream |
| ml-engineer | Read, Write, Edit, Bash, Glob, Grep | sonnet | sklearn/pytorch/xgboost |
| sql-optimizer | Read, Grep, Bash | sonnet | EXPLAIN ANALYZE, query rewrite |
| notebook-narrator | Read, Edit, Glob | haiku | Markdown narrative cells |

### Hooks

| Event | Command | Purpose |
|-------|---------|---------|
| `PostToolUse(Edit\|Write)` `*.py` | `ruff format && ruff check --fix` | Python format/lint |
| `PostToolUse(NotebookEdit)` | `jupyter nbconvert --clear-output` | No outputs in repo |
| `PreToolUse(Bash)` `rm\|drop\|delete` | Validate target not in raw data | Protezione dataset |
| `Stop` | `pytest tests/` if exists | Validate analisi |
| `SessionStart` | Dump `data/` size + disk | Awareness dataset size |

### Community References

- **duckdb/duckdb-skills**: skill pack ufficiale DuckDB
- **VoltAgent/awesome-claude-code-subagents** `/categories/05-data-ai`: data-scientist, ml-engineer, mlops-engineer
- **datalayer/jupyter-mcp-server**: reference impl
- **paulgp.substack.com**: pattern Claude Code per dataset grandi

### Anti-Stack

- ✗ Download dataset enormi via tool calls (brucia context)
- ✗ Dump full DataFrame in context (forza `.head()`, `.shape`)
- ✗ BigQuery MCP + Snowflake MCP insieme (tool overlap > 35 inutili)
- ✗ `NotebookEdit` built-in per `.ipynb` (rompe JSON multi-line)
- ✗ `!pip install` in cella (usa `%pip install`)

---

## Stack C: CLI / Libraries

**Profile**: TypeScript/Python/Rust CLI, SDK, tooling

### MCP Stack

**Principio**: minimalista. Built-in tools coprono 80% del lavoro. Aggiungi MCP solo per esterni reali.

| Server | Repo | Scope | Capability | Token cost | Auth |
|--------|------|-------|------------|------------|------|
| github | github/github-mcp-server | user | PR, release, issue, tag ops | ~6k | OAuth |
| context7 | upstash/context7 | user | Docs lingua/runtime | ~1.5k | None |
| sentry (opzionale) | getsentry/sentry-mcp | user | Crash report da users | ~3k | OAuth |

**Opzionali**: npm-mcp / pypi-mcp / crates-mcp (solo per maintainer multi-package).

**Filosofia**: ogni MCP che duplica cmd line tools è anti-pattern.

### Custom Skills

| Skill | Trigger | Source |
|-------|---------|--------|
| test-driven-development | "implement", "add function" | obra/superpowers |
| systematic-debugging | "bug", "fails", "investigate" | obra/superpowers |
| writing-skills (meta) | "create skill" | obra/superpowers |
| api-design | "design public API" | template custom |
| benchmark-suite | "benchmark", "profile" | template custom |
| release-publish | "release", "publish", "bump version" | template custom |
| changelog-update | implicit pre-release | community |
| cli-help-docs | "update help", "man page" | template custom |

### Sub-agents

| Agent | Tool set | Model | Use case |
|-------|----------|-------|----------|
| code-reviewer | Read, Grep, Glob | sonnet | API breakage, edge cases, naming |
| api-designer | Read, Grep, Glob | sonnet | Public API surface, breaking change check |
| test-author | Read, Write, Edit, Bash, Glob, Grep | sonnet | Property-based + edge case tests |
| doc-writer | Read, Write, Edit, Glob, Grep | haiku | Docstrings, README, examples |
| release-manager | Read, Bash, Grep, Glob | sonnet | Bump version, changelog, tag prep |

### Hooks

| Event | Command | Purpose |
|-------|---------|---------|
| `PostToolUse(Edit\|Write)` language-specific | `cargo fmt` / `gofmt -w` / `ruff format` / `prettier` | Format on save |
| `PostToolUse(Edit)` `*.{py,ts,rs,go}` | Linter | Lint inline |
| `Stop` | Test suite completa | Forza green prima del fine turn |
| `PreToolUse(Bash)` `git tag\|cargo publish\|npm publish` | Conferma esplicita + dry-run | Protezione release accidentale |
| `PostToolUse(Edit)` manifest | Dep check | Coerenza dep tree |

### Community References

- **obra/superpowers**: riferimento per TDD/debug discipline
- **anthropics/skills** `/skills/development-and-technical`: skill ufficiali per MCP gen, testing
- **VoltAgent/awesome-claude-code-subagents** `/categories/02-language-specialists`: typescript-pro, python-pro, rust-engineer, golang-pro
- **affaan-m/everything-claude-code**: harness performance patterns

### Anti-Stack

- ✗ Filesystem MCP (built-in Read/Write/Edit già lì)
- ✗ MCP che wrappa bash commands (`npm-info-mcp` ecc.)
- ✗ Github MCP se lavori solo locally senza PR/issue (`gh` CLI via Bash basta)
- ✗ 20+ skills "just in case"
- ✗ Subagent con tool set = main agent

---

## Stack D: Automation / Scraping / Agents

**Profile**: Python + Playwright + Celery + Anthropic SDK

### MCP Stack

| Server | Repo | Scope | Capability | Token cost | Auth |
|--------|------|-------|------------|------------|------|
| playwright | microsoft/playwright-mcp | project | Browser control, accessibility tree | ~5k | None (local) |
| firecrawl | firecrawl/firecrawl-mcp-server | user | Scrape/crawl/search/research | ~4k | API key |
| github | github/github-mcp-server | user | CI/CD trigger, code deploy | ~6k | OAuth |
| sentry | getsentry/sentry-mcp | user | Error tracking agents prod | ~3k | OAuth |
| context7 | upstash/context7 | user | Docs (Playwright, agent SDK) | ~1.5k | None |
| stagehand (opz) | browserbase/stagehand | project | act/extract/observe primitives | n/a | Browserbase key |

**Trade-off**: Playwright MCP è ~4x più costoso in token vs CLI per task deterministici. Usa MCP solo quando ti serve accessibility-tree-as-context. **Playwright MCP supporta UNA browser session alla volta** → parallel agents richiedono sandbox separati.

### Custom Skills

| Skill | Trigger | Source |
|-------|---------|--------|
| scraping-pattern-detect | "scrape", "extract from site" | template custom |
| robots-respect | implicit pre-scraping | template custom |
| structured-extraction | "extract JSON from page" | template custom |
| anti-bot-handling | "blocked", "captcha" | template custom |
| agent-loop-design | "build agent that..." | template custom |
| error-recovery | implicit on agent crash | template custom |
| job-queue-setup | "queue", "background job" | template custom |
| observability-instrument | "logging", "monitor" | template custom |

### Sub-agents

| Agent | Tool set | Model | Use case |
|-------|----------|-------|----------|
| scraper-architect | Read, Write, Edit, Bash, Grep, Glob, WebFetch | sonnet | Designs scraper: anti-bot, schema, storage |
| browser-automator | Read, Write, Edit, Bash | sonnet | Playwright scripts (deterministic only) |
| data-validator | Read, Bash, Grep | haiku | Schema validation, anomaly flag (read-only) |
| agent-tester | Read, Write, Edit, Bash | sonnet | Eval harness per agent loops |
| deployment-engineer | Read, Write, Edit, Bash, Grep, Glob | sonnet | Dockerfile, CI/CD, sandbox SDK |

### Hooks

| Event | Command | Purpose |
|-------|---------|---------|
| `PreToolUse(WebFetch\|Bash)` domain blocklist | Block scraping host non autorizzati | Compliance/legal |
| `PostToolUse(WebFetch)` | Log URL + size in audit | Audit trail scraping |
| `PostToolUse(Edit\|Write)` `*.py\|*.ts` | Format + lint | Standard quality |
| `PreToolUse(Bash)` `docker push\|fly deploy\|aws ecs` | Dry-run + conferma | Protezione deploy prod |
| `Stop` | Validate schema su output scraped | No silent fail |

### Community References

- **firecrawl/firecrawl-mcp-server**: scraping infra production-grade
- **microsoft/playwright-mcp**: official, accessibility-tree pattern
- **receipting/claude-agent-sdk-container**: containerizzazione SDK production
- **VoltAgent/awesome-claude-code-subagents** `/categories/04-infrastructure`: deployment-engineer, sre-engineer
- **claude-agent-sdk** docs su Managed Agents

### Anti-Stack

- ✗ Parallelizzare più agenti su stesso Playwright MCP (one browser session per server)
- ✗ Firecrawl + Playwright MCP per stesso target senza policy (alterna a caso)
- ✗ WebFetch + WebSearch a scraper deterministico (introduce non-determinismo)
- ✗ Agent SDK in produzione senza sandbox container
- ✗ PAT/API key in `.mcp.json` committato (usa env vars)
- ✗ Scrape senza rate limit + robots.txt check

---

## Transversal Patterns

### Token Budget Governance (critico)

- **Regola del 10%**: se MCP tools > 10% context window, abilita `tool-search` (Claude Code v2.1.7+). Lazy-loada schema.
- **Stima realistica startup**: stack tipici sommano 15-25k token solo in tool definitions prima del primo messaggio.
- **TOON output**: configura MCP servers per output compatto (no null fields) → -50/70% su output tokens.

### Scope Decisions

| Scope | Use case |
|-------|----------|
| `user` | MCP cross-progetto (github, context7, sentry) |
| `project` | MCP project-specific (supabase con project-ref, postgres con connection string, jupyter) |
| `local` (dynamic) | Test rapidi, una sessione |

### Anti-pattern Universali

- ✗ **Kitchen-sink syndrome**: > 5 MCP server in user scope = inflazione context permanente
- ✗ **Skill duplication**: skill custom che replicano superpowers — usa una sola fonte canonical
- ✗ **Tool overlap senza policy**: github + gitlab + bitbucket attivi insieme confondono l'agente
- ✗ **Sub-agent col tool set del main**: subagent value = restrizione context + tool

## Fonti

- [anthropics/skills](https://github.com/anthropics/skills)
- [obra/superpowers](https://github.com/obra/superpowers)
- [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents)
- [Hacker0x01/claude-power-user](https://github.com/Hacker0x01/claude-power-user)
- [travisvn/awesome-claude-skills](https://github.com/travisvn/awesome-claude-skills)
- [How Anthropic teams use Claude Code (PDF)](https://www-cdn.anthropic.com/58284b19e702b49db9302d5b6f135ad8871e7658.pdf)
- [Claude Code best practices](https://code.claude.com/docs/en/best-practices)
- [MCP token overhead analysis](https://www.mindstudio.ai/blog/claude-code-mcp-server-token-overhead)
- [Playwright CLI vs MCP cost benchmark](https://www.morphllm.com/playwright-mcp)
