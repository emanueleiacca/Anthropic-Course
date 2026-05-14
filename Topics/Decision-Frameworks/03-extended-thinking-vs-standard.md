---
title: Framework - Extended Thinking vs Standard
tags: [extended-thinking, reasoning, cost, decision]
last_updated: 2026-05-14
audience: llm-advisory
---

# Framework: Quando usare Extended Thinking vs Standard

**Decisione chiave**: il task richiede ragionamento esplicito multi-step / verifica intermedia / planning, oppure e una trasformazione diretta input→output?

**TL;DR**: Extended Thinking abilita Claude a "pensare ad alta voce" prima della risposta finale. Costa piu token (thinking tokens + output) ma aumenta drasticamente quality su task complessi. Disponibile su Opus 4.7 e Sonnet 4.6+ tramite `thinking: {type: "enabled", budget_tokens: N}`.

## Decision matrix

| Se il task... | Allora... | Perche |
|---------------|-----------|--------|
| Richiede math / proof / logic chains | **Extended thinking ON** (budget 8K-32K) | Riduce errori di calcolo 40-60% |
| E refactor cross-file con dipendenze | Extended thinking ON (budget 16K+) | Planning step evita rework |
| E codice review approfondita | Extended thinking ON (budget 8K) | Catches edge case |
| E debug bug elusivo | Extended thinking ON (budget 16K) | Ipotesi sistematiche |
| E semplice extraction da testo | **Standard** | Overhead non giustificato |
| E classification one-shot | Standard | Latency critica |
| E generation creativa (copy, naming) | Standard | Thinking riduce creativita |
| E summarization | Standard | Pattern lineare |
| E translation | Standard | Mapping diretto |
| E architecture decision | Extended thinking ON (budget 32K) | Trade-off analysis |
| E security review | Extended thinking ON (budget 16K) | Threat modeling step |
| E SQL query authoring complessa | Extended thinking ON (budget 8K) | Join planning |
| E pure tool-call (1-shot) | Standard | Tool decision e veloce |
| E multi-tool orchestration | Extended thinking ON (budget 8K) | Plan-then-execute |
| E retry/recovery dopo errore | Extended thinking ON (budget 4K) | Capisce il fallimento |

## Budget tokens consigliati

| Task complexity | Budget tokens | Costo aggiuntivo (Opus 4.7) | Note |
|-----------------|---------------|------------------------------|------|
| Trivial (classification) | 0 (off) | 0 | Standard suffices |
| Light (single decision) | 2K-4K | ~$0.03 | Quick sanity check |
| Medium (multi-step task) | 8K-16K | ~$0.12-0.24 | Default per coding |
| Heavy (architecture, math) | 16K-32K | ~$0.24-0.48 | Quality > latency |
| Extreme (research-grade) | 32K-64K | $0.48-0.96 | Solo Opus 4.7 |

Pricing reference Opus 4.7 (Mag 2026): $15/M input, $75/M output, thinking tokens fatturati come output.

## Cost / benefit explicit

| Metric | Standard | Extended (16K) | Delta |
|--------|----------|----------------|-------|
| Latency p50 | 2-4s | 8-15s | +4-10s |
| Cost per request | 1x | 1.5-3x | +50-200% |
| Accuracy (coding GSM-style) | ~75% | ~92% | +17pp |
| Accuracy (math AIME) | ~50% | ~85% | +35pp |
| Hallucination rate | baseline | -30-50% | Migliore |

## Quando ASSOLUTAMENTE evitare extended thinking

- **Realtime / streaming voice** (latency budget <500ms)
- **High-frequency batch** (100K+ requests, costo esplode)
- **Cache-heavy multi-turn** (thinking non cachato sempre, perdi benefit caching)
- **Tool use con singolo round** (LLM ha gia tutto il context per decidere)
- **UI/UX latency-critical** (input form completion)

## Pattern di combinazione

### Extended thinking + tool use

```python
client.messages.create(
    model="claude-opus-4-7",
    thinking={"type": "enabled", "budget_tokens": 16000},
    tools=[...],
    messages=[...]
)
```

Thinking precede la decisione tool. Utile per orchestration.

### Extended thinking + prompt caching

ATTENZIONE: thinking output NON e cachato cross-turn. In multi-turn, considera:
- Cache system+tools (statico)
- Thinking fresco a ogni turn (cost overhead)
- Se conversation lunga, valuta thinking solo su key turns

### Extended thinking + structured output

Compatibile. Thinking precede il JSON. Schema validation post-thinking.

### Extended thinking budget dinamico

```
if task_complexity_score > 0.7: budget = 32_000
elif task_complexity_score > 0.4: budget = 8_000
else: thinking_disabled
```

Implementa classifier upstream (Haiku 4.5 e ottimo per scoring).

## Anti-pattern

| Anti-pattern | Sintomo | Fix |
|--------------|---------|-----|
| Thinking ON sempre | Costi 3x | Conditional per task type |
| Budget troncato | Risposta incompleta | Aumenta budget o riduci scope |
| Thinking per classification | Latency inutile | Standard mode |
| Thinking + streaming UI | UX percepita lenta | Mostra "thinking..." indicator |
| Thinking in batch API senza filtering | Costi non lineari | Pre-filtra task con Haiku |

## Riferimenti

- Anthropic docs: Extended Thinking (claude/docs/build-with-claude/extended-thinking)
- Cookbook: Extended thinking patterns
- Claude 4.7 release notes (Apr 2026)
- Vedi anche: [[../Prompting/Advanced/Prompting-Advanced.md]]
