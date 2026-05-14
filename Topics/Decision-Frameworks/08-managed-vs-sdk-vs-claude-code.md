---
title: Framework - Managed Agents vs Agent SDK vs Claude Code
tags: [managed-agents, agent-sdk, claude-code, deployment, decision]
last_updated: 2026-05-14
audience: llm-advisory
---

# Framework: Managed Agents vs Agent SDK vs Claude Code

**Decisione chiave**: l'utente finale interagisce **dove**? Terminale dev (Claude Code), app/server custom (SDK), prodotto Anthropic-hosted (Managed Agents)?

**TL;DR**:
- **Claude Code** = agente coding nel terminale del developer (workstation locale, headless server, IDE)
- **Agent SDK** = libreria Python/TS per costruire agenti custom (full control, own infra)
- **Managed Agents** = piattaforma Anthropic-hosted (no infra, autoscaling, observability built-in)

## Use case matrix

| Use case | Soluzione consigliata | Why |
|----------|----------------------|-----|
| Developer productivity (coding/refactor) | Claude Code | Built per coding workflows |
| CLI tool aziendale per team | Claude Code + custom skills | Skills filesystem-based |
| Backend agent in produzione (SaaS) | Agent SDK | Full control, integra in app |
| Customer-facing chatbot | Managed Agents | Autoscaling, observability |
| Internal copilot per support team | Managed Agents | Hosted, RBAC |
| Long-running autonomous agent (24h+) | Agent SDK + checkpointing | Memory tool, state persistence |
| One-off script automation | Claude Code headless (`claude -p`) | No infra |
| Multi-agent research system | Agent SDK | Custom orchestration |
| Enterprise integration con SSO | Managed Agents | Built-in auth |
| Local-only on-prem deploy | Agent SDK self-hosted | Air-gapped possible |
| Voice agent realtime | Agent SDK + Realtime API | Custom UX layer |
| GitHub Actions / CI automation | Claude Code headless | Single-binary, JSON output |

## Decision tree

```
Q1: L'agent vive dentro un workflow di DEV (coding, refactor)?
├─ Si → Q2: Headless / CI?
│   ├─ Si → Claude Code -p (--print, JSON output)
│   └─ No → Claude Code interattivo
│
└─ No → Q3: E un PRODOTTO end-user che vuoi shippare?
    ├─ Si → Q4: Hai team infra dedicato?
    │   ├─ Si → Agent SDK (control completo)
    │   └─ No → Managed Agents (Anthropic-hosted)
    │
    └─ No (e infra/internal) → Q5: Stateful long-running?
        ├─ Si → Agent SDK + Memory tool + checkpoint
        └─ No → Claude Code headless o Agent SDK
```

## Comparison feature-by-feature

| Feature | Claude Code | Agent SDK | Managed Agents |
|---------|-------------|-----------|----------------|
| **Deployment** | Local CLI / SSH / CI | App/Container/Lambda | Anthropic Cloud |
| **Skills support** | Si (filesystem .claude/) | Si (via SDK) | Si (UI upload) |
| **MCP support** | Si (stdio + HTTP) | Si | Si |
| **Hooks** | Si (PreToolUse, ecc.) | Custom (callback hooks) | Limited |
| **Subagents** | Si (Task tool) | Si (SubagentTool) | Limited |
| **Memory tool** | Si (filesystem) | Si (custom backend) | Built-in |
| **Headless mode** | `claude -p` | Default | Native |
| **Streaming** | Si | Si | Si |
| **Cost model** | Pay-per-token | Pay-per-token | Pay-per-token + platform |
| **Observability** | CLI logs / OTEL | Custom | Built-in dashboards |
| **Auth** | API key | API key / OAuth | SSO, OAuth, RBAC |
| **Auto-scaling** | No (local) | DIY | Built-in |
| **Audit log** | Manual | Manual | Built-in |
| **Compliance (SOC2/HIPAA)** | Self-managed | Self-managed | Anthropic-managed |
| **Custom UI** | TUI only | Full freedom | Limited templates |
| **Setup time** | Minuti | Giorni-settimane | Ore |

## Quando Claude Code

**SI**:
- Workflow dev su workstation
- Coding/refactor/review interattivo
- Headless in CI/CD (GitHub Actions, Jenkins)
- Automation scripts via `claude -p`
- Personalizzazione via `.claude/` (skills, hooks, agents)
- Plugin marketplace ecosystem

**NO**:
- App customer-facing custom UI
- Multi-tenant SaaS
- Necessita compliance Anthropic-managed (SOC2, HIPAA, FedRAMP)

**Esempi**:
- Code review interattivo in repo
- Daily automation via cron + `claude -p`
- Onboarding helper team dev

## Quando Agent SDK

**SI**:
- Building custom product (chat, copilot, agent)
- Hai infra dev team
- Need custom UI/UX
- On-prem / air-gapped
- Integrazione deep con stack esistente
- Multi-modal con API access fine-grained

**NO**:
- Manca infra dev team (overhead alto)
- Use case standard coperto da Managed Agents

**Esempi**:
- SaaS B2B con AI copilot integrato
- Mobile app con AI assistant
- Voice agent realtime (Twilio + SDK)

## Quando Managed Agents

**SI**:
- Vuoi shippare prodotto AI senza gestire infra
- Need built-in: auth, observability, scaling
- Compliance Anthropic-managed
- Quick time-to-market
- Team senza infra esperti

**NO**:
- Custom UX very specifico
- On-prem mandatory
- Integration extremely deep con stack interno

**Esempi**:
- Internal support agent per HR/finance
- Customer chatbot piccola/media azienda
- Document assistant in SharePoint/Slack

## Pattern di combinazione (raro ma valido)

### Hybrid Dev + Prod

- **Dev / iterazione**: Claude Code (loop veloce, skill authoring)
- **Prod**: Agent SDK con same skills + hooks portati

### Managed + SDK escape hatch

- Managed Agents per il 80% standard
- Agent SDK per il 20% di use case custom che richiedono UX speciale

### Claude Code + Managed pipeline

- Sviluppi/test skill in Claude Code
- Upload skill via Managed Agents UI per prod

## Migration paths

| Da | A | Effort | Trigger |
|----|---|--------|---------|
| Claude Code → Agent SDK | Medio | Vuoi UI custom in app |
| Claude Code → Managed | Basso | Vuoi shippare senza infra |
| Agent SDK → Managed | Medio | Tagliare infra ops |
| Managed → Agent SDK | Alto | Need control/customization |

## Anti-pattern

| Anti-pattern | Sintomo | Fix |
|--------------|---------|-----|
| Managed per dev coding workflow | UX clunky, no IDE integration | Claude Code |
| Agent SDK per coding interno | Re-inventi Claude Code | Claude Code + skills custom |
| Claude Code per customer-facing | Niente UX, no scaling | Managed o SDK |
| Stack triplo (CC + SDK + Managed) per stesso use case | Overhead manutenzione | Scegli 1 e standardizza |
| No checkpointing in Agent SDK long-running | Crash perde lavoro | Memory tool + persisted state |
| Hardcode keys in Managed prompt | Security incident | Use secrets manager |

## Riferimenti

- Claude Code docs (claude.com/code)
- Agent SDK (PyPI: `anthropic-agent-sdk`, npm: `@anthropic-ai/agent-sdk`)
- Managed Agents (claude.com/agents, GA 2026-Q1)
- Vedi anche: [[../Claude Code/index.md]] e [[../Agents-MCP/Production/index.md]]
