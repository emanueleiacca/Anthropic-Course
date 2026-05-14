---
title: Playbook - Production observability con OTel
tags: [observability, opentelemetry, otel, tracing, langfuse, honeycomb, agent-eval]
last_updated: 2026-05-14
audience: llm-advisory
---

# Production observability con OpenTelemetry

### Playbook: Tracing agent in production with OTel

**TL;DR**: Setup completo per esportare traces/metrics/logs da Claude Code e Agent SDK a backend OTLP (Honeycomb, Datadog, Langfuse, Grafana, SigNoz). Permette debug remoto, cost tracking per session, identification di spans lenti. Pattern raccomandato per qualsiasi deployment di agent production-grade.

**Contesti applicabili**: Automation | Web (agent production)

**Pre-requisiti**:
- Claude Agent SDK (Python o TS) o Claude Code v2+
- Backend OTLP attivo (es. Honeycomb free tier, SigNoz self-hosted, Langfuse cloud)
- `OTEL_EXPORTER_OTLP_ENDPOINT` configurabile

**Workflow step-by-step**:

1. **Setup base ENV vars** (no code changes needed nel claude-code wrapper):
   ```bash
   export CLAUDE_CODE_ENABLE_TELEMETRY=1
   export OTEL_EXPORTER_OTLP_ENDPOINT=https://api.honeycomb.io
   export OTEL_EXPORTER_OTLP_HEADERS="x-honeycomb-team=$HONEYCOMB_KEY"
   export OTEL_SERVICE_NAME=claude-code-prod
   ```

2. **Spans automatici emessi**:
   - `claude_code.interaction` - top-level per ogni query
   - `claude_code.tool` - per tool call (Read/Edit/Bash/MCP)
   - `claude_code.subagent` - per Task dispatch (nested)
   - `llm_request` - per chiamata API Anthropic (token, model, latency, cost)

3. **Metrics emesse**:
   - `claude_code.tokens_used` (counter, attrs: model, type=input/output/cache_read)
   - `claude_code.cost_usd` (counter)
   - `claude_code.tool_calls` (counter, attrs: tool_name)
   - `claude_code.session_duration_seconds` (histogram)

4. **W3C Trace Context propagation**: se il caller (es. backend Python che dispatch Claude) ha gia un span attivo, l'SDK propaga `TRACEPARENT`/`TRACESTATE` automaticamente → claude_code.interaction diventa child del tuo span applicativo.

5. **Dashboard essenziali** (Grafana/Honeycomb):
   - **Cost per session**: top 10 expensive sessions ultima settimana
   - **Tool latency p50/p95/p99**: identify slow MCP server
   - **Error rate per subagent**: quale sub-agent fallisce piu spesso
   - **Token consumption per model**: split Haiku vs Sonnet vs Opus

6. **Production debugging workflow con traces**:
   - User segnala "agent ha fatto X strano alle 14:23"
   - Trova trace per session_id (filtra in Honeycomb)
   - Vedi sequenza tool call, identifica step problematico
   - Re-run con stesso prompt in dev per riprodurre

7. **Eval regression alert**: connect traces a eval framework:
   - Periodic eval run con golden dataset
   - Score < threshold → PagerDuty alert
   - Compare baseline vs candidate trace (vedi `claude-evals compare`)

**Setup files richiesti**:

```bash
# .envrc (or shell init) - production agent
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
export OTEL_EXPORTER_OTLP_ENDPOINT=https://otlp.eu01.nr-data.net  # or honeycomb/datadog
export OTEL_EXPORTER_OTLP_HEADERS="api-key=$NEWRELIC_LICENSE_KEY"
export OTEL_SERVICE_NAME=claude-code-orchestrator
export OTEL_RESOURCE_ATTRIBUTES="deployment.env=prod,service.version=2.1.4"

# optional: log events to stdout for debug
export OTEL_LOG_LEVEL=debug
```

```python
# Python wrapper esempio - propaga trace context
from opentelemetry import trace
from claude_agent_sdk import query

tracer = trace.get_tracer(__name__)

async def handle_user_request(user_id: str, prompt: str):
    with tracer.start_as_current_span("handle_user_request", attributes={
        "user.id": user_id,
        "prompt.length": len(prompt),
    }) as span:
        # Claude Code SDK automatically propagates W3C context
        # claude_code.interaction span becomes child of this span
        async for msg in query(prompt=prompt):
            yield msg
        span.set_attribute("response.success", True)
```

```yaml
# docker-compose.yml - SigNoz self-hosted setup (estratto)
services:
  claude-code-agent:
    image: my-claude-agent:latest
    environment:
      CLAUDE_CODE_ENABLE_TELEMETRY: "1"
      OTEL_EXPORTER_OTLP_ENDPOINT: http://signoz-otel-collector:4318
      OTEL_SERVICE_NAME: claude-agent
    depends_on:
      - signoz-otel-collector

  signoz-otel-collector:
    image: signoz/signoz-otel-collector:latest
    # ... config
```

**Esempio di sessione tipo (debugging via trace)**:

```
User: ieri alle 14:23 agent ha modificato file errato in prod, trace ID 7a3f...

[Claude opens Honeycomb URL filtered by trace 7a3f]
[Reads span tree]

Claude: Session trace analizzata:
        - claude_code.interaction (12s, model=opus)
        - └ tool Read src/config.ts (50ms)
        - └ tool Grep "DATABASE_URL" (200ms, 8 matches)
        - └ subagent task "fix env var" (8s)
        -   └ llm_request claude-sonnet (3s, 4200 in/890 out)
        -   └ tool Edit src/prod.env (failed: permission deny)
        -   └ tool Edit ../staging/.env (SUCCESS)  ← BUG QUI
        - └ llm_request claude-opus (2s, completion)

Root cause: subagent ha trovato due match per "DATABASE_URL",
ha tentato prod.env (negato dal permission rule),
poi ha provato staging/.env (NON intended, ma allowed).

Fix proposto:
1. Aggiungi permission deny per `Edit(../staging/**)` (cross-project)
2. Subagent prompt: "operate ONLY in $PWD, never traverse .." rule
3. Aggiungi PreToolUse hook che blocca Edit fuori da $PWD

User: applica fix
```

**Metriche di successo**:
- Tempo medio per identificare root cause production bug: <15min (con trace) vs ore senza
- Cost visibility: top 10% session = 60% costo, ottimizzabili con model routing
- Tool latency p95 < 2s (alert se sup)
- Eval regression catched pre-deploy: 80%+ regression bloccate in CI

**Pitfalls comuni**:
- **Telemetry off in prod** → debug remoto impossibile. Sempre `CLAUDE_CODE_ENABLE_TELEMETRY=1` in prod env.
- **No service.name distinto** → traces di multipli agent mischiati. Usa `OTEL_SERVICE_NAME` per ogni deployment.
- **PII nei prompt loggati** → GDPR violation. Configura span processor con redaction o set `CLAUDE_CODE_TELEMETRY_REDACT_PROMPT=1`.
- **Cardinality alta** → user_id come attribute = costi backend esplodono. Hash user_id o usa attribute solo su top-level span.
- **No alerting su cost spike** → bill shock. Alert su `claude_code.cost_usd` > 2x baseline daily.
- **Trace senza correlation app-level** → puoi vedere Claude ma non perche il tuo app code lo ha invocato. Sempre wrap chiamate con tuo span.

**Backend reali a confronto**:
| Backend | Free tier | Best per | Setup |
|---------|-----------|----------|-------|
| Honeycomb | 20M event/mo | trace exploration BubbleUp | ~5min |
| Langfuse | self-hosted free | LLM-specific UI, prompt mgmt | docker compose up |
| SigNoz | self-hosted free | full-stack OTel APM | docker |
| Datadog | trial only | enterprise correlato a APM esistente | agent install |
| Grafana Cloud | 50GB/mo | dashboarding custom | OTLP collector |

**Fonti / Reference reali**:
- [Claude Code OpenTelemetry docs](https://code.claude.com/docs/en/agent-sdk/observability) - spans/metrics ufficiali
- [SigNoz - Bringing Observability to Claude Code](https://signoz.io/blog/claude-code-monitoring-with-opentelemetry/) - setup self-hosted
- [ColeMurray/claude-code-otel](https://github.com/ColeMurray/claude-code-otel) - dashboard ready-made
- [TechNickAI/claude_telemetry](https://github.com/TechNickAI/claude_telemetry) - wrapper `claudia` per drop-in observability
- [Langfuse Claude Agent SDK](https://langfuse.com/integrations/frameworks/claude-agent-sdk) - LLM-specific UI
- [Sealos - Claude Code Metrics Dashboard Grafana](https://sealos.io/blog/claude-code-metrics/) - dashboards template
- [Dynatrace Claude Code monitoring hub](https://www.dynatrace.com/hub/detail/claude-code-agent-monitoring/) - enterprise integration
