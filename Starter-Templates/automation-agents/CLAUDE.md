# <<TODO: automation/agent name>>

Servizio di automazione: <<TODO: scraping target / workflow orchestrato / agent autonomo>>.
SLA: <<TODO: e.g. 99% successful runs/day, p95 < 2min>>.

## Stack

- **Lang**: Python 3.12 (uv) — preferito per ecosystem scraping/agent
- **Browser**: Playwright (chromium) headless + stealth plugins se necessario
- **HTTP**: httpx (async) + tenacity per retry
- **Parsing**: selectolax (HTML), pydantic (data)
- **Queue/Schedule**: Celery + Redis, o Temporal per workflow long-running
- **State**: Postgres per job log, S3-compatible per artifact (HTML cache, screenshot)
- **LLM/Agent**: Anthropic SDK (Claude) + Managed Agents API per loop
- **Observability**: OpenTelemetry → Honeycomb/Tempo; Sentry per errori; structured logs (structlog)

## Layout

```
src/<pkg>/
  scrapers/<site>/      # un modulo per target
  agents/<flow>/        # orchestrazioni LLM
  pipelines/            # ETL job
  storage/              # S3/DB adapters
  schemas/              # pydantic models per output
tests/
  unit/
  integration/          # con fixture HTML/HAR registrati
  e2e/                  # contro target reale (gated, scheduled)
artifacts/              # gitignored
fixtures/               # HTML/HAR snapshot per test deterministici
```

## Commands

```bash
uv sync
uv run python -m <pkg>.cli <command>
uv run pytest tests/unit
uv run pytest tests/integration -m "not e2e"
uv run pytest -m e2e            # solo manuale, hits real sites
uv run ruff check .
uv run mypy src/
uv run playwright install chromium
docker compose up -d redis postgres
uv run celery -A <pkg>.worker worker -l info
```

## Conventions

- **Idempotency**: ogni job ha `idempotency_key`; rerun produce stesso risultato (o no-op).
- **Retry**: tenacity con exponential backoff + jitter; max attempts e timeout per host configurabili. Mai retry su 4xx (eccetto 408/429).
- **Rate limit**: rispetta `Retry-After`; token bucket per host in Redis; circuit breaker dopo N failure consecutivi.
- **Robots/ToS**: check `robots.txt` per scraping pubblico; documenta basis legale per ogni target in `docs/sources/<site>.md`.
- **User-Agent**: identificabile e contattabile.
- **Parsing difensivo**: ogni selettore con fallback; pydantic schema con `extra='ignore'`; log + alert se schema drift.
- **Secrets**: solo via env (`SecretStr` pydantic); mai loggare. Rotazione documentata.
- **Observability**: ogni job → trace span; metriche success_rate, items_extracted, duration_p95 per target.

## Workflow

- Branch: `scraper/<site>`, `agent/<flow>`, `fix/<scope>`.
- PR richiede: fixture HTML/HAR aggiornato, test integration verde, metriche baseline.
- Deploy: container build su tag → staging → canary → prod (10% → 100%).
- Rollback: revert + ridistribuire ultimo tag verde.

## Path-scoped rules

- `src/**/scrapers/**` → @.claude/rules/scraping-ethics.md
- `src/**/agents/**` → @.claude/rules/agent-safety.md
- `src/**/storage/**` → @.claude/rules/data-retention.md

## Vedi anche

Template completo per agents/skills/hooks/rules: vedi `EXTENDED-TEMPLATE.md` in questa directory.
