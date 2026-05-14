---
title: Lookup Table - Task to Solution (60+ entries)
tags: [lookup, task, routing, pattern, advisory]
last_updated: 2026-05-14
audience: llm-advisory
---

# Lookup Table: Task → Solution

**Uso**: dato un task espresso in linguaggio naturale dall'utente, trova la riga semanticamente piu vicina e applica lo stack consigliato.

Legenda colonne:
- **Primary Pattern**: tecnica/architettura principale
- **MCP**: server MCP necessari (`-` = nessuno)
- **Skill**: skill consigliata (ufficiale Anthropic o community, `*` = custom da creare)
- **Subagent**: tipo di subagent da usare (`-` = no subagent)
- **Hook**: hook lifecycle se applicabile
- **Note**: caveat principali

## Development & Code

| Task | Primary Pattern | MCP | Skill | Subagent | Hook | Note |
|------|-----------------|-----|-------|----------|------|------|
| Code review automatizzato su PR | Subagent read-only | github | code-review* | code-reviewer | PreCommit | Trail of Bits checklist |
| Debug bug elusivo (intermittente) | Systematic-debugging + Memory | filesystem | systematic-debugging | Explore | - | Memory tool per ipotesi |
| Setup nuovo progetto da zero | /init + Plan agent | filesystem, github | init | Plan | SessionStart | Genera CLAUDE.md |
| Refactor cross-file (>20 file) | Subagent Plan + Edit batch | filesystem | - | Plan + general-purpose | - | Esegui in branch |
| Aggiungere test mancanti | Skill test-writer + repo scan | filesystem | test-writer* | Explore | PostToolUse (run-tests) | TDD opzionale |
| Migrare codice tra major version | Skill migration + diff analysis | filesystem, github | migration-helper* | Plan | - | Vedi claude-api skill |
| Generare commit message | Skill commit-message | github | commit-message* | - | PreCommit | Conventional commits |
| Git rebase complesso | Subagent Plan + git MCP | git, github | git-workflow* | Plan | - | Backup branch prima |
| Dependency upgrade audit | Skill + SAST + MCP github | github | dependency-audit* | code-reviewer | - | Lockfile diff |
| API contract design | Extended thinking + Plan | - | api-design* | Plan | - | OpenAPI/JSON Schema |
| Performance profiling | Subagent Explore + tool MCP | filesystem | - | Explore | - | Iterative narrowing |
| Security review code | Subagent + SAST skill | github | security-review (Anthropic) | code-reviewer | - | Trail of Bits skill |
| Convert codebase (lang X → Y) | Batch + Skill style guide | filesystem | * | general-purpose parallel | - | Validation pass |

## Data & Files

| Task | Primary Pattern | MCP | Skill | Subagent | Hook | Note |
|------|-----------------|-----|-------|----------|------|------|
| PDF → Markdown estrazione | Skill ufficiale pdf | - | pdf (anthropics/skills) | - | - | Code execution container |
| Excel/CSV → analisi | Skill xlsx + code exec | - | xlsx, csv (anthropics) | - | - | Citations per row |
| Generare PPTX da spec | Skill pptx | - | pptx (anthropics) | - | - | Container API |
| OCR documenti scansionati | Skill + vision API | filesystem | ocr-helper* | - | - | Sonnet 4.6+ vision |
| ETL JSON → DB | MCP database + script | postgres, mysql | * | - | - | Idempotency check |
| Data validation pipeline | Skill schema + pydantic | - | data-validation* | - | PreToolUse | Fail-fast |
| Generate synthetic test data | Code execution + skill | - | data-gen* | - | - | Faker patterns |

## Knowledge & Research

| Task | Primary Pattern | MCP | Skill | Subagent | Hook | Note |
|------|-----------------|-----|-------|----------|------|------|
| Research multi-fonte (web + docs) | Multi-agent parallel | web-search, fetch | research-orchestrator* | general-purpose x3-5 | - | 15x token, 90% quality boost |
| Letteratura review | Subagent + citation tracking | web-search | citation-tracker* | general-purpose | - | Citations API |
| Internal knowledge Q&A | RAG + MCP retrieval | rag-server (custom) | - | - | - | Vector DB |
| Documentation generation | Skill + Explore | filesystem | docs-writer* | Explore | PostToolUse | Sync con codice |
| ADR (Architecture Decision Record) | Skill adr-writer | filesystem | adr-writer* | - | - | Link da CLAUDE.md |
| Meeting notes → action items | Skill + memory | calendar, notion | meeting-parser* | - | - | Notion MCP |

## Productivity & Collaboration

| Task | Primary Pattern | MCP | Skill | Subagent | Hook | Note |
|------|-----------------|-----|-------|----------|------|------|
| Triage GitHub issues | Skill + MCP github | github | issue-triage* | general-purpose | - | Batch su 100+ |
| Slack daily digest | Skill + MCP slack | slack | daily-digest* | - | SessionStart | Schedule cron |
| Email draft sintesi | MCP gmail + skill | gmail | email-summarizer* | - | - | Use create_draft |
| Calendar conflicts | MCP calendar | calendar | - | - | - | suggest_time tool |
| Notion page generation | MCP notion | notion | - | - | - | Pages + databases |
| Onboarding doc new hire | Multi-skill + CLAUDE.md | github, notion | onboarding* | - | - | Template-driven |

## Automation & DevOps

| Task | Primary Pattern | MCP | Skill | Subagent | Hook | Note |
|------|-----------------|-----|-------|----------|------|------|
| Deploy a staging/prod | Skill + MCP k8s/aws | kubernetes, aws | deploy-runbook* | - | PreToolUse (approval) | Human-in-loop |
| Rollback automatico | Hook + skill rollback | kubernetes | rollback* | - | PostToolUse (on-fail) | Health-check trigger |
| Infrastructure as Code | Skill terraform + plan | filesystem, terraform-mcp | terraform-author* | Plan | - | Plan diff review |
| CI/CD pipeline author | Skill ci-builder | github | ci-builder* | - | - | YAML lint |
| Log analysis incident | Subagent + MCP datadog | datadog, sentry | incident-triage* | Explore | - | Time-window narrowing |
| Cron job scheduler | Skill + headless mode | - | * | - | - | claude -p in cron |

## Agentic / Long-running

| Task | Primary Pattern | MCP | Skill | Subagent | Hook | Note |
|------|-----------------|-----|-------|----------|------|------|
| Long-running agent (>1h) | Agent SDK + memory + checkpoint | varies | * | varies | Compaction | Auto-summarize |
| Multi-step workflow stateful | Memory tool + Skill | varies | workflow-runner* | - | - | Resume support |
| Parallel exploration | Multi-agent orchestrator | varies | - | general-purpose x N | - | Token cost x N |
| Computer use (browser) | Computer Use API | - | browser-tasks* | - | PreToolUse (screenshot guard) | Vision-heavy |
| Voice agent | Realtime API + skill | - | voice-handler* | - | - | Streaming tokens |
| Autonomous coding sprint | Claude Code + skill plan | github | sprint-planner* | Plan + general-purpose | Stop (review) | Hours-long |

## Advisory (caso d'uso primario di questa KB)

| Task | Primary Pattern | MCP | Skill | Subagent | Hook | Note |
|------|-----------------|-----|-------|----------|------|------|
| "Quale strumento per X?" | Lookup KB + decision tree | filesystem | this-kb* | - | - | Routing tipico |
| "Genera config Claude Code" | Skill + CLAUDE.md template | filesystem | config-generator* | - | - | Settings hierarchy |
| "Audit setup esistente" | Subagent + skill audit | filesystem | claude-config-audit* | Explore | - | Anti-pattern check |
| "Migrate config v1 → v2" | Skill diff + transform | filesystem | * | - | - | Backup .bak |

## Testing & Quality

| Task | Primary Pattern | MCP | Skill | Subagent | Hook | Note |
|------|-----------------|-----|-------|----------|------|------|
| Eval LLM output quality | Eval framework + judge | - | evaluator* | - | - | LLM-as-judge |
| Regression test suite | Skill + Batch API | - | regression-runner* | general-purpose | - | Snapshot diff |
| Prompt eval matrix | Batch API + Skill | - | prompt-eval* | - | - | A/B test 100 prompt |
| Adversarial testing | Subagent isolato | - | red-team* | general-purpose | PreToolUse (sandbox) | Prompt injection check |

## Security & Safety

| Task | Primary Pattern | MCP | Skill | Subagent | Hook | Note |
|------|-----------------|-----|-------|----------|------|------|
| Secret scanning pre-commit | Hook + skill | github | secret-scan* | - | PreCommit | gitleaks/trufflehog |
| Prompt injection defense | Hook + sandbox subagent | - | injection-guard* | general-purpose (isolated) | PreToolUse | Sanitize untrusted |
| Permission audit | Skill audit + Explore | filesystem | perm-audit* | Explore | - | settings.json deep dive |
| Compliance check (GDPR/SOC2) | Skill checklist | github | compliance* | code-reviewer | - | Audit log |

## Quick decision: 3-second lookup

| Verbo dell'utente | Default stack |
|-------------------|---------------|
| "Crea / Genera" | Skill + tool API |
| "Trova / Cerca" | MCP search + Subagent Explore |
| "Modifica / Refactor" | Skill + Edit tool, eventualmente Plan |
| "Verifica / Audit" | Subagent code-reviewer + Skill |
| "Esegui / Deploy" | Skill + MCP infra + Hook approval |
| "Spiega / Documenta" | Subagent Explore + Skill docs |
| "Riassumi" | Tool API diretto (no MCP) |
| "Memorizza / Ricorda" | Memory tool / CLAUDE.md |
| "Sempre / Quando X fai Y" | Hook |
| "Quando X allora Y (contextually)" | Skill o CLAUDE.md |

## Cross-reference

- Decision tree completo: [[01-decision-tree-tool-choice.md]]
- Anti-pattern: [[09-anti-patterns-catalog.md]]
- Model selection: [[06-model-selection.md]]
