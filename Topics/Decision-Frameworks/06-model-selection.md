---
title: Framework - Model Selection (Opus 4.7 / Sonnet 4.6 / Haiku 4.5 / Mythos)
tags: [model, opus, sonnet, haiku, mythos, decision, cost]
last_updated: 2026-05-14
audience: llm-advisory
---

# Framework: Quale model per quale task

**Decisione chiave**: bilanciare **task complexity vs latency budget vs cost sensitivity**. Non tutto richiede Opus.

**TL;DR**: Opus 4.7 = frontier reasoning. Sonnet 4.6 = best balance (default). Haiku 4.5 = high-volume / classifier. Mythos Preview = experimental long-context / multi-modal.

## Lineup attuale (Maggio 2026)

| Model | Model ID | Context | Pricing (in/out per 1M tok) | Caratteristica |
|-------|----------|---------|------------------------------|----------------|
| **Opus 4.7** | `claude-opus-4-7` | 500K | $15 / $75 | Frontier reasoning, extended thinking |
| **Sonnet 4.6** | `claude-sonnet-4-6` | 1M | $3 / $15 | Default; SWE-bench top, agentic |
| **Haiku 4.5** | `claude-haiku-4-5` | 200K | $0.80 / $4 | Fast, cheap, classifier-ready |
| **Mythos Preview** | `claude-mythos-preview` | 2M | $5 / $25 | Long-context, multi-modal vision/audio |

(Pricing maggio 2026, Anthropic API. Disponibili anche via AWS Bedrock e GCP Vertex.)

## Decision matrix per task type

| Task type | Model consigliato | Alternativa | Note |
|-----------|-------------------|-------------|------|
| Frontier reasoning (math proof, research) | Opus 4.7 | - | Solo Opus |
| Architecture / system design | Opus 4.7 + thinking 32K | Sonnet 4.6 | Quality > cost |
| Complex coding (>5 file refactor) | Sonnet 4.6 | Opus 4.7 se ambiguity alta | Sonnet best on SWE-bench |
| Code review approfondita | Sonnet 4.6 | Opus 4.7 per critical | Subagent code-reviewer |
| Quick code edit | Sonnet 4.6 | Haiku 4.5 per tweak | Sonnet default |
| Coding agent loop (Claude Code) | Sonnet 4.6 | Opus per task hard | Best balance |
| Q&A su docs interne | Sonnet 4.6 | Haiku 4.5 se RAG forte | Cache amico |
| Classification (intent, label) | Haiku 4.5 | Sonnet se context lungo | $0.80/M |
| Extraction strutturata | Haiku 4.5 | Sonnet per schema complex | Tool use |
| Summarization breve | Haiku 4.5 | Sonnet per nuance | Latency win |
| Summarization long-doc (>200K) | Mythos Preview | Sonnet 4.6 con chunking | 2M context |
| Translation | Haiku 4.5 | Sonnet per literary | Routine fluent |
| Vision OCR / image understanding | Mythos Preview | Sonnet 4.6 | Mythos meglio audio+vision |
| Audio transcription/analysis | Mythos Preview | - | Solo Mythos in preview |
| Creative writing (long-form) | Opus 4.7 | Sonnet 4.6 | Opus per voice |
| Marketing copy | Sonnet 4.6 | Haiku 4.5 per varianti | Sonnet creativo |
| Customer support bot | Sonnet 4.6 | Haiku 4.5 per FAQ | Latency budget |
| Realtime voice agent | Haiku 4.5 + streaming | Sonnet se complex | Latency critical |
| Multi-agent orchestrator | Opus 4.7 | Sonnet 4.6 se cost-sensitive | Top of hierarchy |
| Multi-agent worker | Sonnet 4.6 | Haiku 4.5 per task split | Gradient |
| Eval / LLM-as-judge | Sonnet 4.6 | Opus per critical | Coerenza valutazioni |
| Synthetic data gen | Haiku 4.5 | Sonnet per nuance | Volume win |
| Embeddings (semantic search) | (Voyage / esterno) | - | Anthropic non offre embeddings |
| Computer use (browser) | Sonnet 4.6 | Opus 4.7 | Sonnet computer-use optimized |
| Long-running agent (>1h) | Sonnet 4.6 | Opus per kickoff | Cost over hours |

## Decision tree latency/cost

```
Q1: Latency budget <500ms?
├─ Si → Haiku 4.5 (streaming)
└─ No → Q2: Cost sensitivity alta (high-volume)?
    ├─ Si → Q3: Task complexity?
    │   ├─ Low → Haiku 4.5
    │   ├─ Medium → Sonnet 4.6
    │   └─ High → Sonnet 4.6 + extended thinking
    └─ No → Q4: Frontier-level reasoning?
        ├─ Si → Opus 4.7
        └─ No → Q5: Context >500K?
            ├─ Si → Mythos Preview o Sonnet 4.6 (1M)
            └─ No → Sonnet 4.6 (default)
```

## Quando usare Opus 4.7

**SI**:
- Task con ambiguity alta, richiede deep reasoning
- Multi-agent orchestrator
- Architecture/security review critica
- Math/proof/scientific reasoning
- Quality > cost di 10x

**NO**:
- Volume elevato (cost esplode)
- Latency-critical
- Task lineare/deterministico (overkill)

## Quando usare Sonnet 4.6

**Default** per il 70% dei task. Particolarmente forte su:
- SWE-bench coding tasks (#1 al 2026-Q1)
- Agentic loop / tool use
- Computer use (versione tuned)
- 1M context window

## Quando usare Haiku 4.5

**SI**:
- Classifier / routing
- High-volume batch (>10K request)
- Realtime / low-latency
- Pre-filter prima di Opus/Sonnet
- Synthetic data generation

**NO**:
- Reasoning complesso
- Multi-step planning
- Creative high-quality

## Quando usare Mythos Preview

**SI**:
- Context >1M token (legal docs, codebase enorme)
- Audio + vision combinati
- Multi-modal research
- Sperimentazione cutting-edge

**NO**:
- Workload produzione critica (preview = SLA limitato)
- Cost-sensitive (pricing intermedio ma context push costoso)

## Tiered routing pattern

Pattern produzione: classifier upstream → model selection.

```python
def select_model(task):
    if task.type == "classification": return "haiku-4-5"
    if task.requires_vision: return "mythos-preview"
    if task.complexity_score > 0.8: return "opus-4-7"
    return "sonnet-4-6"  # default
```

Costo: ~50% in meno vs always-Opus.

## Cross-provider considerations

| Provider | Models | Note |
|----------|--------|------|
| Anthropic API | tutti i 4 | Latency migliore, feature-complete |
| AWS Bedrock | Opus 4.7, Sonnet 4.6, Haiku 4.5 | Enterprise compliance |
| GCP Vertex AI | Opus 4.7, Sonnet 4.6, Haiku 4.5 | GCP-native integration |
| Mythos Preview | Solo Anthropic API | Preview features |

## Anti-pattern

| Anti-pattern | Sintomo | Fix |
|--------------|---------|-----|
| Opus per tutto | Cost 5-10x necessario | Tiered routing |
| Haiku per reasoning complex | Output scadente, retry loop | Sonnet 4.6 |
| Sonnet per realtime <300ms | Latency miss | Haiku streaming |
| Hardcode model ID in 100 file | Migration pain | Const centralizzata |
| Non testare upgrade Sonnet 4.5 → 4.6 | Regressioni invisibili | Eval suite |
| Mythos in prod sotto SLA | Preview = no SLA | Sonnet 4.6 in prod |

## Riferimenti

- Anthropic Pricing page (claude.com/pricing, maggio 2026)
- Model card Opus 4.7 (Apr 2026)
- SWE-bench leaderboard
- Vedi anche: [[../Foundations/Modelli e versioni Claude.md]]
