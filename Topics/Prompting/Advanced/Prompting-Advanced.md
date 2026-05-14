---
title: Prompt Engineering Avanzato
tags: [prompting, extended-thinking, caching, structured-output, citations]
last_updated: 2026-05-14
---

# Prompt Engineering Avanzato

Tecniche avanzate: extended thinking, prompt caching, structured output, citations, batch processing.

## Extended Thinking (Adaptive)

Reasoning step-by-step interno controllato via `effort` (low/medium/high/xhigh/max). Interleaved thinking automatico con tool use su Opus 4.7/4.6/Sonnet 4.6.

```python
thinking={"type":"adaptive","effort":"high"}
```

Tutti i thinking tokens fatturati come input (anche se nascosti). Con `display: "omitted"` il thinking field è vuoto ma signature criptata persiste per continuità multi-turn.

**Use cases**: Problemi complessi multi-step, agentic tasks tool-heavy, quando qualità > latenza

**Timing token**: Opus 4.7 interleaved con tool, cost circa 3-5x single-pass ma quality migliore

## Prompt Caching Strategy

Cache del prefisso via `cache_control: {"type":"ephemeral"}` (max 4 breakpoint/request).

**TTL**: `5m` (1.25× write cost) o `1h` (2× write cost)

**Read cost**: 10% input

**Breakpoint placement**: Sul last block che resta identico across requests

**Cache hierarchy**: Tools → System → Messages

**Min tokens**: Opus 4.7/4.6 = 4096, Sonnet 4.6 = 1024, Haiku 4.5 = 4096

**Auto-caching**: Passa `cache_control` top-level, il sistema piazza il breakpoint automaticamente

```python
response = client.messages.create(
    model="claude-opus-4-7",
    system=[
        {"type":"text","text":long_system,"cache_control":{"type":"ephemeral","ttl":"1h"}},
    ],
    messages=conversation_history + [{"role":"user","content":[...]}],
)
print(response.usage.cache_read_input_tokens)
```

## Structured Output (JSON Schema + Strict Tools)

Grammar-constrained decoding per output garantito-valido.

```python
response = client.messages.parse(
    model="claude-opus-4-7",
    max_tokens=2048,
    output_format=Issue,  # Pydantic model
    messages=[...],
)
issue: Issue = response.parsed_output
```

**Limiti**:
- Incompatibile con Citations API
- JSON Schema limitato (no recursive, no minLength, no additionalProperties: true)
- Max 20 strict tools per request

**Modelli supportati**: Opus 4.7, 4.6, 4.5, Sonnet 4.6/4.5, Haiku 4.5

## Tool Design Patterns

**Naming**: `service_action` (snake_case), namespace per service

**Description**: 3-4 frasi, spiega il WHEN, cita positivo/negativo

**Consolidate**: Meglio 1 tool con `action` enum che 10 tool simili

**Parallel tool use**: Default ON. Boost con prompt system esplicito.

**Strict tool**: `"strict": true` per schema-compliant garanzia

## Multi-Turn Conversation Engineering

**Gestire context** via:
- System message stabile (cacheable)
- Tool result pruning (rimuovi/troncate vecchi)
- Server-side compaction (beta `compact-2026-01-12`)
- Claude Code `/compact`

**Context rot**: Degrado accuracy con riempimento; Opus 4.6+ introduce adaptive compaction

**Inversion of attention**: Info verso il fondo hanno più peso → metti istruzioni critiche vicino a user message corrente

**Subagents**: Compaction nativa — conversazione laterale isolata, torna solo summary

## Citations API

Quote esatte verificabili da documenti forniti, con character/page/block indices.

```python
response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    messages=[{
        "role": "user",
        "content": [
            {
                "type": "document",
                "source": {"type":"text","media_type":"text/plain","data": doc_text},
                "title": "Policy v2",
                "citations": {"enabled": True},
            },
            {"type": "text", "text": "What is parental leave duration?"}
        ]
    }],
)
```

**Incompatibile con Structured Outputs**

## Batch API

Async processing fino a 10K request, completamento < 1h, **50% sconto input/output**.

```python
batch = client.messages.batches.create(
    requests=[
        {
            "custom_id": f"eval-{i}",
            "params": {"model":"claude-opus-4-7","max_tokens":2048,"messages":[...]}
        }
        for i, prompt in enumerate(prompts)
    ]
)
# Poll status, stream results
```

**Compatibile con**: Tool use, vision, prompt caching, citations, extended thinking

## Chain of Thought vs Extended Thinking

**Explicit CoT**: Prompting "think step by step" + `<thinking>` tags, output text fatturato pieno

**Extended Thinking**: Model-level reasoning, thinking tokens invisibili o sommarizzati

**Combinare**: Extended thinking + structured CoT = doppio reasoning (caro ma robusto)

Su Opus 4.7: Preferire Extended Thinking adaptive

## Meta-Prompting & Prompt Improver

Usare Claude per migliorare prompt automaticamente via Anthropic Console.

**Pipeline**: Example ID → Draft → CoT refinement → Example enhancement

Output tipico: Structured XML prompt con `<instructions>`, `<context>`, `<examples>`, `<thinking>`, `<answer>`

## XML Tags & System Prompt Strategy

**Tag standard**: `<instructions>`, `<context>`, `<input>`, `<data>`, `<example>`, `<document>`, `<thinking>`, `<answer>`, `<format>`, `<rules>`

**Prefill response**: Forzare inizio output con `<thinking>\n` o `{` o `<answer>` per skip preamble

**System prompt**: Ruolo + facts stabili + format, cacheable

**Nesting OK**: `<documents><document index="1"><content>...</content></document></documents>`

**Order matters**: Info verso il fondo ha più peso (inverse attention)

## Vedi Anche

- [[../../Agents-MCP/Agent Patterns/]]
- [[../../Claude Code/Claude-Code-Advanced]]
- [[../../API-Tools/Tool Use Avanzato]]
