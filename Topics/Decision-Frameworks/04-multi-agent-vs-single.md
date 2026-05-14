---
title: Framework - Multi-Agent vs Single Agent
tags: [multi-agent, orchestration, subagent, cost, decision]
last_updated: 2026-05-14
audience: llm-advisory
---

# Framework: Quando usare Multi-Agent vs Single Agent

**Decisione chiave**: il task ha sub-task **paralleli, indipendenti, con context disgiunti**? Se si, multi-agent vale il costo. Se no, single agent vince.

**TL;DR**: Multi-agent (orchestrator + N subagent) costa ~15x token di un single agent ma puo offrire +90% quality su task di research/synthesis. Per task lineari, e overhead puro.

## Cost vs Quality trade-off

Studio Anthropic (Research mode 2025-Q4) su task di deep research:

| Setup | Token cost (rel) | Quality score | Latency |
|-------|------------------|---------------|---------|
| Single Opus 4.7 | 1x | baseline | baseline |
| Single Opus + extended thinking 32K | 1.8x | +30% | +3x |
| Orchestrator + 3 subagent parallel | 8x | +60% | +1.5x |
| Orchestrator + 5 subagent parallel | 15x | +90% | +2x |
| Orchestrator + 10 subagent parallel | 28x | +95% | +2.5x (parallel) |

**Sweet spot**: 3-5 subagent per la maggior parte dei task. Oltre 7-8 il marginal benefit crolla e i context conflicts aumentano.

## Decision matrix

| Se il task... | Allora... | Perche |
|---------------|-----------|--------|
| Richiede **research multi-fonte** | Multi-agent (3-5) | Parallelismo + isolamento context |
| Richiede **N file da modificare indipendentemente** | Multi-agent (N) o batch | Embarrassingly parallel |
| E **sequenziale con dipendenze** | Single agent | Multi-agent introduce coord overhead |
| Richiede **sintesi cross-domain** | Orchestrator + subagent specializzati | Domain expertise per subagent |
| E **simple Q&A** | Single agent | Multi-agent e overkill |
| Richiede **adversarial validation** | Multi-agent (generator + critic) | Pattern Plan-and-Solve |
| E **long-running >1h** | Multi-agent + checkpointing | Failure isolation |
| Richiede **>100K token context** | Multi-agent (split context) | Aggira context limit |
| E **deterministic transform** | Single agent | No benefit dal parallelism |
| Richiede **eval di N candidate** | Multi-agent + judge | Best-of-N pattern |

## Quando usare Multi-Agent: signals positivi

1. **Token budget elevato** (research-grade, willing to pay 10-15x)
2. **Quality > Latency > Cost** in priority
3. **Sub-task indipendenti** (no inter-agent dependencies)
4. **Context isolation utile** (un agent non deve vedere context altrui)
5. **Synthesis finale critica** (orchestrator aggrega)
6. **Adversarial robustness** richiesta (cross-validation)

## Quando NON usare Multi-Agent: signals negativi

1. **Latency-critical** (UX <5s)
2. **Cost-sensitive** (high-volume API)
3. **Task lineare** (step1 → step2 → step3)
4. **Dipendenze inter-step strette**
5. **Coordination overhead > task complexity**
6. **Output deterministico atteso**

## Pattern multi-agent comuni

### Orchestrator-Workers (default)

```
Orchestrator (Opus 4.7)
├── Worker 1 (Sonnet 4.6): research domain A
├── Worker 2 (Sonnet 4.6): research domain B
├── Worker 3 (Sonnet 4.6): research domain C
└── Synthesis: orchestrator unisce
```

Use case: deep research, multi-source synthesis.

### Plan-and-Execute

```
Planner (Opus 4.7) → genera task graph
├── Executor 1: subtask A
├── Executor 2: subtask B (depends on A)
└── ...
Validator: verifica risultato finale
```

Use case: complex coding, deploy pipelines.

### Generator-Critic

```
Generator (Sonnet 4.6) → produce N candidate
Critic (Opus 4.7) → score e seleziona
[iterate fino convergenza]
```

Use case: creative writing, code review.

### Hierarchical (rare, costly)

```
Manager
├── Lead 1 → workers 1A, 1B, 1C
├── Lead 2 → workers 2A, 2B
```

Use case: organizational simulation, autonomous research labs.

## Implementation in Claude Code

```yaml
# .claude/agents/research-orchestrator.md
---
name: research-orchestrator
description: Multi-domain research with parallel subagent dispatch
tools: Task, WebFetch, WebSearch
---

Use Task tool to spawn parallel general-purpose subagents,
one per domain. Synthesize after all return.
```

In Agent SDK:
```python
from anthropic.tools import SubagentTool
# Each spawn = isolated context window
```

## Anti-pattern multi-agent

| Anti-pattern | Sintomo | Fix |
|--------------|---------|-----|
| Multi-agent per task lineare | Costo 15x senza benefit | Single agent + extended thinking |
| 20+ subagent paralleli | Context conflicts, costo lineare | Cap a 5-7, batch se necessario |
| Subagent senza role chiaro | Output ridondante | Description specifica + scope disgiunto |
| Orchestrator stesso modello dei workers | No expertise gradient | Opus orchestrator + Sonnet workers |
| Nessuna synthesis step | Output frammentato | Sempre finalizer (orchestrator) |
| Shared mutable state tra agent | Race condition | Fork context, append-only memory |
| Subagent puo spawnare altri subagent | Costo esplode | Limit depth=1 by default |

## Decision tree finale

```
Q1: Sub-task INDIPENDENTI tra loro?
├─ No → Single agent (+extended thinking se complesso)
└─ Si → Q2: Token budget supporta 10-15x cost?
    ├─ No → Single agent (sequential) o Batch API
    └─ Si → Q3: Quality boost critico?
        ├─ Si → Multi-agent 3-5 workers (sweet spot)
        └─ No → Single agent
```

## Riferimenti

- Anthropic "Building effective agents" (Engineering blog 2024-Q4)
- Anthropic Research mode multi-agent architecture (2025)
- Claude Code subagent docs
- Vedi anche: [[../Agents-MCP/Agent Patterns/Subagents e task delegation.md]]
