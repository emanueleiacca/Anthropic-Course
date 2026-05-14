---
title: Anti-pattern Catalog - 25+ errori reali con fix
tags: [anti-pattern, mistakes, fixes, lessons-learned]
last_updated: 2026-05-14
audience: llm-advisory
---

# Anti-pattern Catalog

Catalogo di errori **realmente documentati** dalla community Anthropic (engineering blog, top maintainer, security audit Trail of Bits, devrel posts). Ogni voce: **Anti-pattern → Sintomo → Cosa fare invece → Riferimento**.

## Configurazione & Memory

| Anti-pattern | Sintomo | Cosa fare invece | Riferimento |
|--------------|---------|------------------|-------------|
| **CLAUDE.md con 500+ righe** | Context bloat, slow load, dilution | Split in skill `.claude/skills/*/SKILL.md` con `paths` glob | Anthropic engineering "Memory in long-context" |
| **CLAUDE.md duplicato in subfolder** | Conflitti, sovrascritture | Tieni 1 file root + skill scoped | Claude Code docs settings hierarchy |
| **Hardcode segreti in CLAUDE.md o skill** | Leak nei commit | `.env` + secrets manager, mai inline | Trail of Bits skill audit (2026-Q1) |
| **Skill senza description nel frontmatter** | Skill mai invocata dal LLM | `description:` chiara con keywords trigger | Skills cookbook Anthropic |
| **Skill con allowed-tools `*`** | Surface attack massiva | List puntuale, fully-qualified `MCP:tool` | Trail of Bits |
| **Settings.local.json committato in git** | Override accidentali team | `.gitignore` settings.local.json | Claude Code docs |

## Tool & MCP

| Anti-pattern | Sintomo | Cosa fare invece | Riferimento |
|--------------|---------|------------------|-------------|
| **MCP server "monolite" con 50+ tools** | Token bloat, LLM confusa | Split in 3-5 server tematici | MCP best practices 2026 |
| **Tool description vaga ("does stuff")** | LLM sbaglia routing | Description con esempi, input/output schema | Anthropic tool use cookbook |
| **MCP server senza rate limiting** | API esterno bannato | Rate limit lato server, retry exponential | Production MCP guide |
| **Skill che fa HTTP requests inline** | Bypass design, hard to test | Crea MCP server e chiama via allowed-tools | Skills vs MCP guide |
| **Tool che ritornano blob >50K token** | Context window saturato | Truncate + paginate, return summary + ID | Anthropic agentic patterns |
| **No timeout su tool calls** | Agent loop blocca per ore | Timeout per tool (default 30s) | Hooks docs |
| **MCP transport stdio per server condiviso** | Nessun multi-client | HTTP/SSE transport | MCP spec 2025-12 |

## Agent design

| Anti-pattern | Sintomo | Cosa fare invece | Riferimento |
|--------------|---------|------------------|-------------|
| **Multi-agent per task lineare** | Costo 15x senza benefit | Single agent + extended thinking | "Building effective agents" Anthropic |
| **Subagent ricorsivi senza depth limit** | Cost explosion, infinite spawn | Cap depth=1, monitor cost | Production agents guide |
| **No checkpoint in long-running agent** | Crash = lavoro perso | Memory tool + persisted state ogni N step | Long-running agents pattern |
| **Stesso modello per orchestrator e workers** | No expertise gradient | Opus orchestrator, Sonnet workers | Multi-agent research |
| **Agent loop senza max_iterations** | Loop infiniti su retry | `max_iterations=20`, Stop hook fallback | Claude Code defaults |
| **Subagent context shared mutable** | Race conditions, output corrotto | Fork context, append-only memory | Agent SDK docs |
| **Tool result inietta untrusted in system** | Prompt injection vector | Sanitize + isolated subagent | Trail of Bits security |

## Prompting

| Anti-pattern | Sintomo | Cosa fare invece | Riferimento |
|--------------|---------|------------------|-------------|
| **Extended thinking ON per tutto** | Costo 3x, latency 5x | Conditional (task complexity classifier) | Extended thinking guide |
| **Few-shot examples fuori da cached zone** | Cache miss continuo | Examples PRIMA del breakpoint | Prompt caching docs |
| **Cache breakpoint dopo user message** | Hit rate 0% | Breakpoint prima del turn user | Prompt caching |
| **Timestamp in system prompt** | Cache invalidata ogni request | Timestamp in user message | Prompt caching gotchas |
| **Roleplay "ignore previous instructions"** | Prompt injection success | XML tag delimiters + system hard-coded | Anthropic prompt eng guide |
| **JSON output senza structured output API** | Parsing errors, retry | Use `response_format` o tool with strict schema | Structured output docs |
| **Lunghezza output mai vincolata** | Risposte verbose, costo | `max_tokens` + esempi few-shot brevi | Cost optimization |

## Claude Code specifico

| Anti-pattern | Sintomo | Cosa fare invece | Riferimento |
|--------------|---------|------------------|-------------|
| **Hardcode skill content in CLAUDE.md** | Skill non riusabile | Skill folder dedicata `.claude/skills/<name>/` | Claude Code skills docs |
| **Hook PostToolUse che blocca con sleep lungo** | UX freeze | Hook async / exit 0 fast | Hooks lifecycle |
| **No hook PreToolUse per destructive ops** | git reset --hard accidentale | PreToolUse approval per Bash su comandi blacklist | Settings.json permissions |
| **Subagent invocato per task <5K token** | Overhead context isolation > benefit | Inline (no Task tool) | Subagents docs |
| **Claude Code headless senza JSON output** | Parsing scraping fragile | `claude -p --output-format json` | Headless mode |
| **Plugin install da sorgente non verificata** | Supply chain risk | Marketplace ufficiale o repo trusted | Plugin security 2026 |
| **CLAUDE.md scritto come prose lunga** | LLM scarsa retention | Bullet, tabelle, esempi compatti | CLAUDE.md guide |

## Cost & Performance

| Anti-pattern | Sintomo | Cosa fare invece | Riferimento |
|--------------|---------|------------------|-------------|
| **Opus per classification high-volume** | Costo 5-10x necessario | Haiku 4.5 classifier upstream | Model selection guide |
| **No prompt caching su agent loop** | Costo lineare su context cresce | Cache breakpoint dopo tools+system | Prompt caching |
| **Streaming disabilitato su UX realtime** | Time-to-first-token alto | `stream=True` sempre per chat | API best practices |
| **Re-invio full conversation history ogni turn** | Costo quadratico | Cache + memory tool / summarization | Multi-turn patterns |
| **Cache 1h TTL con 2 hit/h** | Non si ripaga (2x write cost) | 5m TTL o no cache | Prompt caching pricing |
| **Batch API per request <100** | Overhead non giustificato | API standard | Batch API docs |
| **Test eval suite full su ogni commit** | CI lento | Sample 10% + full su release | Eval-driven dev |

## Security

| Anti-pattern | Sintomo | Cosa fare invece | Riferimento |
|--------------|---------|------------------|-------------|
| **Skill esegue codice non sandboxed da untrusted source** | RCE potential | Code execution container API | Skills security |
| **Tool MCP con auth condivisa team** | No audit per-user | OAuth flow per-user, RBAC | MCP auth 2026 |
| **Logging full prompt + risposta in chiaro** | PII leak | Redact PII, encrypt at rest | Compliance guide |
| **No prompt injection filter su tool result** | Agent obbedisce a payload | Filter + isolated subagent + warning | Trail of Bits |
| **Permission `Bash:*` allow-all** | Comandi distruttivi senza approval | Allowlist comandi safe, deny pericolosi | Settings.json permissions |
| **API key in env nel container Docker public** | Leak su image registry | Use secret mounts, never bake in image | Container security |

## Observability / Production

| Anti-pattern | Sintomo | Cosa fare invece | Riferimento |
|--------------|---------|------------------|-------------|
| **No tracing su multi-agent chain** | Debug impossibile | OpenTelemetry + agent ID propagation | Production observability |
| **No eval suite prima deploy** | Regressioni invisibili | Eval-driven dev, golden set | Anthropic eval cookbook |
| **Solo metriche di latency, no quality** | Drift silenzioso | LLM-as-judge + manual sample | Eval guide |
| **Deploy modello upgrade senza A/B** | Rollback caotico | Canary 5% + eval comparativa | Model upgrade pattern |
| **No retry/backoff su 529 (overloaded)** | Errori in produzione | Exponential backoff + circuit breaker | API best practices |

## Quick fix table

| Sintomo osservato | Causa probabile | Fix immediato |
|-------------------|-----------------|---------------|
| LLM ignora skill | description debole | Riscrivi description con keywords trigger |
| Cache hit rate <30% | Breakpoint malposizionato | Sposta prima del turn user |
| Costo API 3x previsto | Opus su task semplici | Tiered routing con Haiku classifier |
| Loop di tool infinito | No max_iterations | Set cap + Stop hook |
| Subagent risultati ridondanti | Scope non disgiunto | Description specifica per ogni subagent |
| Hook blocca tutto | Exit code sbagliato | Verifica 0=ok, 2=block intenzionale |
| Prompt injection riuscito | Tool result non sanitizzato | Isolated subagent + delimiter XML |
| Skill non discovered | Filename SKILL.md sbagliato | Maiuscolo `SKILL.md` + frontmatter valid |
| Context window pieno | Mancata compaction | Hook Compaction + memory tool |
| MCP server crash | No retry + no health check | Restart policy + health endpoint |

## Riferimenti

- Anthropic engineering blog "Building effective agents" (2024-12)
- Trail of Bits "Security review of Claude Skills" (2026-Q1)
- Claude Code official documentation
- MCP spec 2025-12
- Cookbook patterns (anthropics/anthropic-cookbook)
