---
title: MCP Ecosystem - Reference Completo
tags: [mcp, ecosystem, index, servers]
last_updated: 2026-05-14
---

# MCP Ecosystem - Reference Completo

Guida esaustiva su Model Context Protocol: architettura, server ufficiali e community, transport, security, produzione.

## Catalogo MCP Reference Servers (Ufficiali)

| Server | Categoria | Descrizione | Stato |
|--------|-----------|-------------|-------|
| **Everything** | Testing/Demo | Server di reference con esempi di prompts, resources e tools | Active |
| **Fetch** | Data Access | Recupera contenuto web, converte HTML → markdown | Active |
| **Filesystem** | File Mgmt | Operazioni file con access controls | Active |
| **Git** | Development | Read/search/manipulate repo Git locali | Active |
| **Memory** | Storage | Knowledge graph persistente cross-session | Active |
| **Sequential Thinking** | Reasoning | Catene di pensiero riflessive | Active |
| **Time** | Utilities | Conversioni timezone e formati data | Active |

## Temi Principali

### 1. Transport
- **stdio** (default locale): veloce, single-user, no auth nativa
- **Streamable HTTP** (remoto): scalabile, multi-tenant, OAuth 2.1 + PKCE obbligatorio
- **SSE-only** (deprecato mar 2025): non usare per nuovo codice

### 2. Authentication
- OAuth 2.1 + PKCE obbligatorio per server remoti pubblici
- Resource Indicators (RFC 8707) per token scoping
- Client ID Metadata Documents (2025-11-25) come alternativa a Dynamic Client Registration

### 3. Advanced Features
- **Tools** (azioni): tool che modificano stato
- **Resources** (dati): read-only, referenziabili dal client
- **Prompts**: workflow guidati
- **Roots**: boundary filesystem/workspace dal client
- **Sampling**: server delega ragionamento al modello del client
- **Elicitation** (draft): domande mid-task all'utente

### 4. Custom Server Development
- **SDK Python** (FastMCP): decorator-based, auto JSON Schema da type hints
- **SDK TypeScript**: lower-level, ESM-only
- Tool design per LLM: namespacing `service_action`, descrizione 3+ frasi con when/not-when
- Strict schema validation con Zod/Pydantic

### 5. Production
- Rate limiting (token bucket)
- Error model (400/403/404/429 machine-readable, messaggi actionable)
- Observability: structured logs + Prometheus + OpenTelemetry
- Versioning semantico, additive change preferita
- Capability handshake al `initialize`

### 6. Security
- **Tool poisoning**: cambio description dopo approvazione iniziale
- **Prompt injection**: dati esterni che includono istruzioni
- **Least privilege**: separare read vs write, tool scoping
- **Sandbox**: OS-level (bubblewrap/seatbelt) per tool eseguiti
- **HITL checkpoint**: delete, send money, push to main richiedono user confirmation
- **Tool pinning**: `mcp-scan` genera hash della description, rileva cambi

### 7. MCP in Claude Code
- Config via `.mcp.json` (project scope, versionato) o `~/.claude.json` (user)
- Scoping: local > project > user > enterprise
- Workspace trust dialog a every nuovo server

### 8. Code Execution con MCP
- Pattern Anthropic (nov 2025): agent scrive TypeScript/Python che orchestra MCP tool
- Riduzione token fino a 98.7% su task complessi
- Sandbox essenziale
- Data intermedi non entrano in context (solo output finale)

### 9. MCP Registry & Discovery
- Registry ufficiale `registry.modelcontextprotocol.io` (preview sett 2025, GA 2026)
- Alternative: PulseMCP, Glama, Smithery, GitHub MCP Registry
- Metadata standardizzato: nome, version, install command, transport, capabilities

### 10. Writing Tools for Agents
- **Naming**: `service_action` (snake_case), namespace per service
- **Description**: 3-4 frasi, spiega il WHEN, cita positivo/negativo
- **Consolidate**: meglio 1 tool con `action` enum che 10 tool simili
- **Parallel tool use**: default ON, boost con prompt sistem esplicito
- **Validation**: misura `avg_tools_per_tool_call_message` per parallelism
- **Strict tool** (`strict: true`): garanzia schema-compliant input

## Key Facts 2026

- SSE-only deprecato: usare stdio (locale) o Streamable HTTP (remoto)
- OAuth 2.1 + PKCE mandatorio da 2025-11-25
- Tool poisoning è attacco documentato: difesa = tool pinning (`mcp-scan`)
- Ecosystem: ~97M SDK download/mese, 10.000+ server pubblici
- Prompt Caching opera su tool definitions (cacheable)

## Vedi Anche

- [[Skills Ecosystem|../../API-Tools/Skills/]]
- [[Agent Patterns - Production|../Production/]]
- [[Tool Use Avanzato|../../API-Tools/Claude API/Tool Use Avanzato]]
