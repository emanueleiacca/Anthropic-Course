---
title: Playbook - Performance optimization end-to-end
tags: [performance, profiling, optimization, n+1, hot-path, load-testing]
last_updated: 2026-05-14
audience: llm-advisory
---

# Performance optimization end-to-end

### Playbook: Profile → identify → fix → verify

**TL;DR**: Workflow per ottimizzare performance senza APM dedicato: Claude Code instrumenta l'app, identifica bottleneck (DB query, business logic, network), implementa fix, verifica con load test. Specialista per DB (N+1, missing index), business logic e bundle size. Pattern ufficiale "Optimize code performance quickly" di Anthropic.

**Contesti applicabili**: Web | Data (Python/Node piu coperti)

**Pre-requisiti**:
- Endpoint o funzione con bottleneck noto (latency p95 > target)
- Test/staging environment con dati realistici
- Profiler installabile (`py-spy`, `clinic.js`, Chrome DevTools, EXPLAIN ANALYZE)

**Workflow step-by-step**:

1. **Reproduce baseline**:
   - Misura latency baseline: p50/p95/p99 con load test (`autocannon`, `wrk`, `k6`)
   - Salva baseline.json (numeri)
   - Identifica endpoint/funzione target (worst offender)

2. **Profiling tier-by-tier** (most common to least):
   - **Tier 1 DB**: query slow log, EXPLAIN ANALYZE, ORM N+1 detection
   - **Tier 2 Business logic**: CPU profiler, hot path identification
   - **Tier 3 Network/external**: tracing, dependency latency
   - **Tier 4 Bundle/render** (frontend): bundle analyzer, React profiler

3. **Specialized sub-agent dispatch**:
   - `db-performance-agent` - legge schema, ORM model, route handler; suggerisce index, query rewrite, batch
   - `code-performance-agent` - identifica nested loop, redundant serialization, sync I/O su path async

4. **Fix iterativo, una opt alla volta**:
   - Implement fix
   - Run load test
   - Confronta vs baseline
   - Commit se miglioramento >5%, revert altrimenti
   - Repeat su next bottleneck

5. **Verification con load test reproducible**:
   - k6/autocannon script committato in repo
   - CI gate: PR fail se p95 regression >10%

**Setup files richiesti**:

```yaml
# .claude/agents/db-performance-agent.md
---
name: db-performance-agent
description: Analyzes DB performance issues. N+1, missing index, query rewrite. Reads ORM models, route handlers, migration files.
model: opus
tools: Read, Grep, Glob, Bash(psql*, sqlite3*, EXPLAIN*)
---

When given an endpoint or query:
1. Trace data access:
   - Read route handler
   - Identify ORM calls (prisma, drizzle, sequelize, sqlalchemy)
   - Read referenced models
2. Detect anti-patterns:
   - N+1: loop with await query (per-iteration) → use includes/eager load
   - Missing index: WHERE/ORDER BY on non-indexed column → propose CREATE INDEX
   - SELECT *: large rows when subset needed → projection
   - No pagination: full-table scan → LIMIT/OFFSET or cursor
3. Verify with EXPLAIN ANALYZE on staging DB
4. Output: { issues: [...], fixes: [...], expected_impact: "5-20x" }
```

```yaml
# .claude/agents/code-performance-agent.md
---
name: code-performance-agent
description: Identifies hot paths in business logic. Suggests optimizations without changing semantics.
model: opus
tools: Read, Grep, Bash(py-spy*, clinic*, node --prof*)
---

1. Attach profiler:
   - Python: `uv run py-spy record -o profile.svg -- python -m app`
   - Node: `clinic doctor -- node app.js`
2. Identify top 3 hot frames
3. For each frame:
   - Nested loop on small array (acceptable) vs large (problem)
   - Sync I/O in async context (red flag)
   - JSON.parse/serialize per call (cacheable?)
   - Object allocation in hot loop (reuse?)
4. Propose fix preserving semantics + test plan
```

```javascript
// load-test/baseline.js (k6 script)
import http from 'k6/http';
import { check } from 'k6';

export const options = {
  scenarios: {
    constant_load: {
      executor: 'constant-vus',
      vus: 50,
      duration: '60s',
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'],
  },
};

export default function() {
  const res = http.get('https://staging.example.com/api/orders?workspaceId=test');
  check(res, { 'status 200': r => r.status === 200 });
}
```

**Esempio di sessione tipo**:

```
User: /api/orders e lento, p95=2.3s su 50 vus. Target p95<500ms.

Claude: Phase 1 - profiling tier-by-tier.

[Tier 1: DB]
[dispatch db-performance-agent]
db-agent: [Read src/api/orders/route.ts]
[Read src/db/queries/orders.ts]
N+1 DETECTED: getOrders() loops orders, then per-iteration:
  - query items: `db.select().from(items).where(orderId)`
  - query customer: `db.select().from(customers).where(id)`
50 orders × 2 queries = 100 extra round trips.
Fix: eager load via Drizzle `with: { items: true, customer: true }`

Also: missing index on orders.workspaceId (full scan).
Propose: CREATE INDEX idx_orders_workspace ON orders(workspaceId);

Claude: Apply fix 1 (eager load):
[Edit src/db/queries/orders.ts]
[Bash: pnpm test orders -- PASS]
[Bash: k6 run load-test/baseline.js]
Result: p95 2.3s → 520ms. Big win.

Apply fix 2 (index):
[Edit drizzle migration]
[Bash: pnpm db:push]
[Bash: k6 run]
Result: p95 520ms → 180ms. Target hit.

[Tier 2: still room for improvement?]
[Code profiler shows JSON.serialize of nested items takes 80ms]
Optimize: streaming response.
[Edit handler to use streaming]
Result: p95 180ms → 95ms.

Commit "perf: eager load orders, add workspaceId index, stream response".
```

**Metriche di successo**:
- p95 latency entro target (es. <500ms)
- DB query count per request: identifiable e ottimizzato (no N+1)
- Bundle size: ridotto entro budget (frontend)
- Load test in CI: regression bloccata automaticamente

**Pitfalls comuni**:
- **Premature optimization**: ottimizzare prima di misurare. Forza baseline + profile prima di toccare codice.
- **Single-fix mentality**: applicare 5 fix together, non si sa chi ha aiutato. Una opt alla volta, misura tra ogni.
- **Profiler in prod senza throttle**: profiler 100% sampling = down. Usa sampling rate basso o staging.
- **Micro-optimization su non-hot path**: ottimizzare loop chiamato 10x quando il problema e una query 100ms. Sempre identifica top 3 hot.
- **Cache invalidation ignorata**: aggiungi cache "for speed" → bug stale data. Define TTL + invalidation strategy upfront.
- **Bundle bloat dimenticato**: Claude add lib senza check tree-shake. Hook PostToolUse Edit per warn bundle size delta.

**Varianti per contesto**:
- **Data/ML**: aggiungi profiling pandas (`%%time`, `memory_profiler`), focus su vectorization vs loop
- **CLI**: focus su startup time (lazy import in Python, esbuild bundling in Node)
- **API**: aggiungi step di cache layer (Redis hot path) dopo DB fix

**Fonti / Reference reali**:
- [Anthropic Claude blog - Optimize code performance quickly](https://claude.com/blog/optimize-code-performance-quickly) - workflow ufficiale
- [Developer Toolkit - Performance Analysis from the Terminal](https://developertoolkit.ai/en/claude-code/lessons/performance/) - profile Node/Python/DB senza APM
- [Application Profiler Claude Skill](https://mcpmarket.com/tools/skills/application-performance-profiler) - skill marketplace
- [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) - performance optimization system
- [Developer Toolkit - Performance Tuning](https://developertoolkit.ai/en/claude-code/advanced-techniques/performance-tuning/) - DB + business logic deep dive
- [Anthropic case: Growth Marketing ad optimization](https://claude.com/blog/how-anthropic-teams-use-claude-code) - CSV pipeline ottimizzata con sub-agent
