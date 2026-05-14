---
title: Framework - Prompt Caching Strategy
tags: [caching, prompt-caching, cost, ttl, breakpoint]
last_updated: 2026-05-14
audience: llm-advisory
---

# Framework: Prompt Caching Strategy

**Decisione chiave**: il contenuto e **stabile e riusato** in piu chiamate entro la finestra TTL? Se si, cache. Definisci dove mettere i breakpoint.

**TL;DR**: Prompt caching riduce costi input fino a **90%** e latency fino a **80%** su prompt ripetuti. Anthropic supporta 2 TTL: **5 minuti** (default, no cost extra) e **1 ora** (2x cost write, 0.1x cost read). Max 4 cache breakpoint per request.

## Pricing reference (Maggio 2026, Opus 4.7)

| Operazione | Costo (vs base input) |
|------------|----------------------|
| Cache write 5m | 1.25x base |
| Cache read 5m | 0.1x base (90% sconto) |
| Cache write 1h | 2x base |
| Cache read 1h | 0.1x base |
| No cache | 1x base |

Break-even: cache write 5m si ripaga al **2° hit**. Cache 1h si ripaga al **9° hit**.

## Decision tree

```
Q1: Lo stesso prefix sara riusato in <5 min?
├─ No → Q2: Sara riusato in <1 h?
│   ├─ No → SOLUTION: NO cache
│   └─ Si → Q3: Hit rate atteso >9?
│       ├─ Si → SOLUTION: Cache 1h TTL
│       └─ No → SOLUTION: NO cache (1h non si ripaga)
└─ Si → Q4: Prefix >1024 token (Opus/Sonnet) o 4096 (vecchi)?
    ├─ No → NO cache (sotto minimo)
    └─ Si → SOLUTION: Cache 5m TTL (default)
```

## Quando attivare cache: scenari

| Scenario | TTL | Breakpoint position | Hit rate atteso |
|----------|-----|---------------------|-----------------|
| Multi-turn chatbot | 5m | After system prompt | Alta (ogni turn) |
| Multi-turn agent con tools | 5m | After tools array | Alta |
| RAG con context corpus stabile | 5m o 1h | After context | Media-alta |
| Code review batch 100+ file | 1h | After system+rules | Molto alta |
| Few-shot prompting | 5m | After examples | Alta in batch |
| Evaluation suite 1000+ task | 1h | After prompt template | Molto alta |
| One-shot extraction | NO cache | - | 1 (no riuso) |
| Streaming voice realtime | NO cache | - | Latency >> caching benefit |
| Agent loop con state diverso | 5m parziale | Solo prefix immutabile | Variabile |

## Breakpoint placement decision tree

Anthropic supporta **max 4 breakpoint** per request. Posizionali in ordine di stabilita decrescente.

```
Q: Cosa va PRIMA del breakpoint (cached) vs DOPO (fresh)?
├─ Tools/MCP descriptions → SEMPRE cached (Brk #1)
├─ System prompt (instructions, persona) → SEMPRE cached (Brk #2)
├─ Few-shot examples → cached se stabili (Brk #3)
├─ Document context (RAG retrieved) → cached se riusato (Brk #4)
└─ User message turn corrente → MAI cached (fresh)
```

### Esempio struttura request ottimale

```
[tools]                    ← Breakpoint 1 (cache 1h)
[system: instructions]     ← Breakpoint 2 (cache 1h)
[user: example 1]
[assistant: example 1]
[user: example 2]
[assistant: example 2]     ← Breakpoint 3 (cache 5m)
[user: context document]   ← Breakpoint 4 (cache 5m)
[user: current question]   ← NO cache
```

## TTL 5m vs 1h: decision matrix

| Se... | TTL consigliato | Perche |
|-------|-----------------|--------|
| Conversational chat (turni <5min) | 5m | Default, no extra cost |
| Batch processing piu lungo di 5min | 1h | Evita re-write costoso |
| Evaluation suite (eseguita per ore) | 1h | Worth 2x write cost |
| Agent autonomous long-running | 1h con refresh | Lavoro asincrono |
| RAG context refreshed ogni 10min | 1h | Evita re-cache penalty |
| Demo / one-shot | NO cache | Niente da riusare |
| A/B test prompt comparison | 1h | Stessa baseline su 100+ trial |

## Pattern di combinazione

### Caching + Extended thinking

ATTENZIONE: thinking output NON e cacheable. Cache TUTTO prima del turn corrente.

```
[tools]                    ← cached
[system]                   ← cached
[turn N-1 user/assistant]  ← cached
[turn N user]              ← fresh
[thinking generato]        ← non cachato
[response]
```

### Caching + Batch API

Anthropic Batch API supporta caching. Strategia: stesso prefix (system + tools) cached, varia solo user message. **Massima efficienza per eval batch**.

### Caching + Tool use multi-turn

In agent loop, dopo OGNI tool result, il context cresce. Strategia:
- Cache fino a tools+system (immutable)
- Tool results vanno DOPO il breakpoint (fresh)
- Refresh breakpoint ogni 4-5 turni se context post-breakpoint diventa enorme

## Cache invalidation triggers

La cache viene invalidata se:
- Cambia anche 1 token PRIMA del breakpoint
- Cambia ordine di tools array
- Cambia model version (4.6 vs 4.7)
- Scade TTL (5m o 1h)
- Cambia max_tokens? **No**, max_tokens non invalida
- Cambia stop_sequences? **No**

## Anti-pattern

| Anti-pattern | Sintomo | Fix |
|--------------|---------|-----|
| Cache breakpoint dopo user message | Hit rate 0% (user cambia ogni turn) | Spostare PRIMA del turn user |
| Cache 1h con 2-3 hit attesi | Non si ripaga | Usa 5m o no cache |
| 5+ breakpoint richiesti | Limite Anthropic = 4 | Consolida |
| Variare ordine tools/messages | Cache miss continuo | Stabilizza ordering |
| Cache su prompt <1024 token | Sotto minimo, ignorato | Aumenta prefix o no cache |
| Includere timestamp in system | Cache invalidata ogni request | Sposta timestamp fuori cached zone |
| Re-cache write inutile | Cost overhead | Verifica TTL non scaduto via cache_creation_input_tokens=0 |

## Metriche da monitorare

| Metrica | Where | Target |
|---------|-------|--------|
| `cache_read_input_tokens` | API response | >80% di input cached |
| `cache_creation_input_tokens` | API response | basso steady-state |
| Cost reduction % | Billing dashboard | -60% a -90% |
| TTL hit rate | Custom tracking | >50% per 5m, >30% per 1h |

## Riferimenti

- Anthropic docs: Prompt Caching (claude/docs/build-with-claude/prompt-caching)
- Cookbook: prompt_caching.ipynb
- Blog: "Prompt Caching with Claude" (2024-08)
- 1-hour TTL release (2024-12)
- Vedi anche: [[../API-Tools/Claude API/Prompt Caching.md]] e [[../Prompting/Advanced/Prompting-Advanced.md]]
