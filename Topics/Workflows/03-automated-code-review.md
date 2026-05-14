---
title: Playbook - Code review automatizzato (locale + CI)
tags: [code-review, subagent, github-actions, hooks, pre-commit, CI]
last_updated: 2026-05-14
audience: llm-advisory
---

# Code review automatizzato (locale + CI)

### Playbook: Two-layer automated code review

**TL;DR**: Pattern a due strati - hooks locali (dev-time, fast feedback) + GitHub Action `claude-code-action` (CI-time, deep review con sub-agent multipli). Catch issue prima del commit E prima del merge. Pattern ufficiale del plugin Anthropic `code-review`.

**Contesti applicabili**: Tutti

**Pre-requisiti**:
- Claude Code installato in dev
- Repo GitHub con admin access (per installare action)
- `ANTHROPIC_API_KEY` come repo secret

**Workflow step-by-step**:

1. **Layer 1 - Hook locale pre-commit** in `.claude/settings.json`:
   - PostToolUse Edit/Write → auto-format (biome/ruff/gofmt)
   - PreToolUse Bash `git commit*` → trigger subagent `reviewer` su staged changes
   - Subagent ritorna severity. Critical = block (exit 2). Warning = log.

2. **Layer 2 - GitHub Action** per PR: `/install-github-app` da Claude Code (admin) genera workflow base.

3. **Workflow CI parallel reviewers** (pattern del plugin ufficiale `anthropics/claude-code/plugins/code-review`):
   - Step Haiku pre-check: skip se PR draft/closed/già reviewed
   - Step Haiku: find tutti i CLAUDE.md rilevanti per file modificati
   - Step Sonnet: PR summary
   - Step parallel (4 agenti):
     - 2 Sonnet → CLAUDE.md compliance
     - 1 Opus → bug detection
     - 1 Opus → security/logic
   - Step parallel validation: subagent verifica ogni finding (rimuove false positive)
   - Output: inline comments via `mcp__github_inline_comment__create_inline_comment`

4. **Solo HIGH SIGNAL**: regola obbligatoria del plugin ufficiale:
   - Flag: syntax/type errors, missing imports, logic bugs, CLAUDE.md violations
   - **Non flag**: style, pedanteria, subjective preferences, "potenziali" issue

5. **Custom slash command** `/review-pr` (pattern Trail of Bits): parallel agents (pr-review-toolkit + Codex + Gemini), aggrega findings, push fix automatici.

**Setup files richiesti**:

```yaml
# .github/workflows/claude-review.yml
name: Claude Code Review
on:
  pull_request:
    types: [opened, synchronize]
    paths:
      - 'src/**'
      - '!**/*.md'

jobs:
  review:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
      issues: write
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: anthropics/claude-code-action@v1
        with:
          prompt: |
            Review this PR using the /code-review slash command from the
            anthropics/claude-code-plugin marketplace.
            Focus on HIGH SIGNAL issues only:
            - Syntax/type errors, missing imports
            - Logic bugs (off-by-one, null deref, race)
            - Security (SQLi, XSS, secrets, auth bypass)
            - CLAUDE.md violations (cite rule)
            Skip style/pedantic suggestions.
          claude_args: '{"model":"claude-opus-4-7"}'
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

```yaml
# .claude/agents/reviewer.md (used by local hook)
---
name: reviewer
description: Reviews staged changes for HIGH SIGNAL bugs. Used proactively before commits.
model: opus
tools: Read, Grep, Glob, Bash(git diff --staged*, git status*)
---

Run `git diff --staged` and analyze. Output ONLY:

## CRITICAL (block commit)
- path:line - description (exit 2)

## WARNING (proceed but inform)
- path:line - description

## NONE
If no findings: output "No issues found."

Rules:
- Cite CLAUDE.md if violation: "violates CLAUDE.md L42: 'no any in TypeScript'"
- Suggest fix only if obvious one-liner
- IGNORE: style, formatting (handled by linter), subjective preferences
```

```json
// .claude/settings.json - local pre-commit hook
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{
          "type": "agent",
          "agent": "reviewer",
          "condition": "$CLAUDE_TOOL_INPUT matches '^git commit'",
          "on_critical": "block"
        }]
      }
    ]
  }
}
```

**Esempio di sessione tipo (locale)**:

```
User: commit these changes
Claude: [Bash: git status]
        [Bash: git add .]
        [PreToolUse hook fires: dispatch reviewer subagent]

[reviewer subagent runs]
Reviewer: ## CRITICAL
- src/auth.ts:45 - Missing await on bcrypt.compare(); returns Promise, always truthy
- src/api/users.ts:12 - SQL injection: user input concatenated into query, use parameterized

## WARNING
- src/lib/format.ts:8 - unused import 'lodash'

Exit code 2 (blocked)

Claude: Commit bloccato. 2 issue critici da fixare prima di committare:
        1. Fix bcrypt await in auth.ts:45
        2. Parametrizza query in api/users.ts:12
        Procedo con i fix?
User: yes
[fix, retry commit, hook re-runs, passes]
```

**Esempio di sessione tipo (CI)**:

```
PR #142 opened
[claude-code-action runs]
[parallel 4 subagents review]
[validation pass: 2 issues confirmed, 1 false positive removed]
[inline comments posted on PR]

Inline comment on src/lib/cache.ts:23:
  CRITICAL: Race condition - check-then-set on Redis.
  Use SETNX or Redis lock. CLAUDE.md L67 requires atomic ops.
  Suggested fix:
  ```ts
  const acquired = await redis.set(key, val, 'NX', 'EX', ttl);
  ```
```

**Metriche di successo**:
- false-positive rate < 10% (misurabile da reazioni "👎" sui comment)
- bug catch rate misurato vs human review: superpowers reporta 60-70% overlap
- PR review time: human review da 30min → 5min (Claude pre-filtra)
- 0 production incidents da bug catch-able dal reviewer nel mese

**Pitfalls comuni**:
- **Reviewer "nitpicky"** → ondata di comment stile/pedanti, dev ignora tutto. Forza "HIGH SIGNAL ONLY" nel prompt e blocca commenti senza file:line concreto.
- **Hook bloccante con falsi positivi** → dev disattiva l'hook. Inizia con `warning-only`, passa a `block` solo dopo 2 settimane di calibration.
- **CI senza pre-check** → ogni push triggera review costoso. Aggiungi Haiku pre-check (skip draft/automated PR).
- **No validation step** → Claude flagga ipotesi, dev perde tempo. Pattern ufficiale: 4 reviewer → validation subagent → output.
- **Stesso modello per tutto** → over-spend. Usa Haiku per filtraggio, Sonnet per summary, Opus solo per bug/security deep.

**Fonti / Reference reali**:
- [anthropics/claude-code-action GitHub](https://github.com/anthropics/claude-code-action) - action ufficiale, YAML templates
- [anthropics/claude-code code-review plugin](https://github.com/anthropics/claude-code/blob/main/plugins/code-review/commands/code-review.md) - workflow ufficiale 9-step
- [Trail of Bits claude-code-config /review-pr](https://github.com/trailofbits/claude-code-config) - parallel multi-agent review pattern
- [systemprompt.io - Claude Code GitHub Actions PR Review](https://systemprompt.io/guides/claude-code-github-actions) - guide pratica
- [Claude Code HTTP Hooks × GitHub Actions](https://claudelab.net/en/articles/claude-code/claude-code-http-hooks-cicd-github-actions-guide) - two-layer pattern (locale + CI)
- [freddo1503/claude-pre-commit](https://github.com/freddo1503/claude-pre-commit) - pre-commit hook valida config Claude
