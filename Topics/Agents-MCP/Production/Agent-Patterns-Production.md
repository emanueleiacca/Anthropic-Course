---
title: Agent Patterns - Production & Advanced Topics
tags: [agents, patterns, production, orchestration]
last_updated: 2026-05-14
---

# Agent Patterns - Production & Advanced Topics

Panoramica dei pattern avanzati per agenti in produzione: orchestrazione, memory, observability, evaluation.

## Multi-Agent Orchestration

**Pattern**: Lead agent (Opus) decompone task, delega a sub-agent specializzati (Sonnet) in parallelo, sintetizza risultati. Multi-agent Opus 4 + Sonnet 4 supera single-agent Opus 4 del 90.2%.

**Use cases**: Research, code analysis, multi-source synthesis, alto branching factor

**Modelli**: Orchestrator-worker, sectioning (parallel indipendenti), voting (N esecuzioni stesso task)

## Sub-agents

**Pattern**: AI assistenti specializzati con context window e tool set isolati. Defined in `.claude/agents/<name>.md` o programmaticamente via Agent SDK.

**Features**:
- Context isolation (no conversation history ereditata)
- Tool set ristretto per blast radius
- Auto-delegation basata su description
- Stateless per semplicità

**Limiti**: NON possono spawnare altri sub-agent (max depth 1)

## Agent Memory

**Memory Tool** (`memory_20250818`): filesystem `/memories` persistente cross-session. Just-in-time retrieval pattern: non caricare tutto upfront, agent legge solo ciò che serve.

**Patterns**:
- Structured artifacts (progress.md, decisions.md, checklist.md)
- Assume interruption: scrivere progress continuamente
- Multi-session: initializer crea checkpoint, riprese legge per primo

## Long-Running Agents

**Requisiti**: Append-only event log, checkpoint dopo step major, durable session log, compaction + memory combo

**Checkpoint cadence**: Dopo ogni tool execution major; resume dal last checkpoint

**Anthropic Managed Agents**: $0.08/session-hour + token cost, checkpoint automatici, memory hosting

## Agent Evaluation

**Non è eval di LLM**: Valuti la sistema (tool calls, trajectories, side effects, end-state)

**Dataset**: 20-50 task da failure reali, mix deterministic + LLM-as-judge + human grading

**Grader hierarchy**: Deterministic → LLM-judge → human spot-check (calibration)

**Production regression**: Ogni bug riportato aggiunto al regression set

## Agent Observability

**3 pilastri**: Traces (OTLP) + Metrics (token, cost, decisions) + Logs (structured JSON)

**Span names**: `claude_code.interaction`, `claude_code.llm_request`, `claude_code.tool`, `claude_code.hook`

**W3C Trace Context**: TRACEPARENT propagato in child process per nesting span

**End-user attribution**: `enduser.id` e `tenant.id` via OTEL_RESOURCE_ATTRIBUTES per audit per-utente

## Production Patterns: Rate Limit, Retry, Fallback, Timeout

**429 vs 529 vs 5xx**:
- 429: quota org tier (rispetta retry-after)
- 529: capacity Anthropic (retry ma non contro budget)
- 5xx: errore applicativo

**Exponential backoff + jitter**: 1s, 2s, 4s, 8s + random ±20%

**Rate limit categories**: RPM, ITPM, OTPM — monitorare i 3

**Fallback chain**: Opus → Sonnet → Haiku per task degradabili

**Circuit breaker**: Dopo N failure, route a fallback per finestra T

## Security Patterns per Agenti

**Defense-in-depth**: Trusted-site whitelist + permission prompts + OS-level sandbox + tool authorization + output validation

**3 layer (Claude Code)**:
1. Trusted-site whitelist
2. Permission prompts (allow/deny/ask)
3. OS sandbox (bubblewrap Linux / seatbelt Mac)

**Permission modes**: `default` (ask), `acceptEdits`, `plan`, `bypassPermissions` (dangerous)

**Indirect prompt injection**: Payload non da utente, da dati (email, web, file)

## Computer Use

**Use case**: Sistemi legacy senza API, task richiedenti visual judgment

**Loop**: Screenshot → reasoning → action → screenshot

**Cost**: Ogni screenshot = input image, scala male su task lunghi

**Sandbox richiesto**: Action arbitrarie su OS richiedono isolation

## Workflow Patterns: Chaining, Routing, Evaluator-Optimizer

**Prompt chaining**: Pipeline lineare, ogni step input del successivo

**Routing**: Classifier instrada a specialista (Haiku per triage, Opus per execution)

**Evaluator-optimizer**: Loop generator/critic, stop su quality threshold o N iter

## SDK & Managed Agents

**Agent SDK** (open-source): Self-hosted, Python/TS, full control

**Managed Agents** (hosted): $0.08/session-hour, memory + sandbox + checkpoint managed, API-driven

**Trade-off**: SDK = controllo; Managed = velocità produzione

## Vedi Anche

- [[../Agent Patterns/]]
- [[Extended Thinking|../../Prompting/Advanced/Extended-Thinking]]
- [[Context Engineering|../../Prompting/Advanced/Context-Engineering]]
