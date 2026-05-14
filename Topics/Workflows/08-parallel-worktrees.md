---
title: Playbook - Parallel workflow con git worktrees
tags: [git-worktree, parallel, tmux, isolation, multi-agent, productivity]
last_updated: 2026-05-14
audience: llm-advisory
---

# Parallel workflow con git worktrees

### Playbook: Multi-feature parallel development

**TL;DR**: Esegui 3-5 sessioni Claude Code in parallelo, ciascuna in proprio git worktree con env isolato (port distinti, DB branch separato, .env locale). Pattern usato da obra/superpowers (auto-create worktree per feature) e da Stripe per parallel migration. Massimizza throughput dev rispetto a sequenze single-session.

**Contesti applicabili**: Web | CLI (codebase con test suite veloce)

**Pre-requisiti**:
- Git 2.5+ (worktree support)
- Test framework che gestisce port dinamici o test parallelizzabili
- DB con branching (Neon, Planetscale) o DB locale per worktree
- tmux/zellij/screen per multi-pane terminal (opzionale ma raccomandato)

**Workflow step-by-step**:

1. **Crea worktree dedicato per feature**:
   ```bash
   git worktree add ../proj-feat-auth feature/auth
   git worktree add ../proj-feat-billing feature/billing
   git worktree add ../proj-bugfix-csv hotfix/csv-export
   ```

2. **Isola environment per worktree**:
   - Copia (non symlink) `.env` in ogni worktree
   - Override `PORT` in `.env.local`: feat-auth→3001, feat-billing→3002, bugfix-csv→3003
   - DB: branch separato (Neon: `neon branches create --name feat-auth`) o DB locale dedicato

3. **Worktree-aware AGENTS.md / CLAUDE.md**:
   - File root condiviso (architecture, conventions)
   - Append per-worktree in `.claude/local-context.md` (task corrente)

4. **Launch parallel sessions** (tmux):
   ```bash
   tmux new-session -d -s claude-parallel
   tmux send-keys "cd ../proj-feat-auth && claude" Enter
   tmux split-window -h
   tmux send-keys "cd ../proj-feat-billing && claude" Enter
   tmux split-window -v
   tmux send-keys "cd ../proj-bugfix-csv && claude" Enter
   tmux attach
   ```

5. **Shared task board** (opzionale): markdown in root repo che tutti gli agent leggono in SessionStart hook:
   - `tasks/active.md` con assignment + status

6. **Merge strategy**:
   - Ogni worktree → PR separato
   - Merge in ordine di completion (priority + risk)
   - Dopo merge: `git worktree remove ../proj-feat-X`

7. **Anti-collision**:
   - Mai due agent sullo stesso file path: ogni feature deve operare su scope disjoint
   - Se necessario: file conflict resolution manuale

**Setup files richiesti**:

```bash
#!/usr/bin/env bash
# scripts/wt-new.sh - crea worktree con env isolato
set -euo pipefail

FEATURE=$1
BASE=${2:-main}

git worktree add "../$(basename $PWD)-$FEATURE" -b "feature/$FEATURE" "$BASE"
cd "../$(basename $PWD)-$FEATURE"

# Copy .env (no symlink)
cp ../$(basename $PWD | sed "s/-$FEATURE//")/.env .
echo "" >> .env.local

# Assign next available port
USED_PORTS=$(grep -h "PORT=" ../*-*/.env.local 2>/dev/null | grep -oP '\d+' || echo "3000")
NEXT_PORT=$(( $(echo "$USED_PORTS" | sort -n | tail -1) + 1 ))
echo "PORT=$NEXT_PORT" >> .env.local

# Create DB branch (Neon)
neon branches create --name "$FEATURE" --parent main || true
DB_URL=$(neon branches get-connection-string "$FEATURE")
echo "DATABASE_URL=$DB_URL" >> .env.local

# Install deps in worktree
pnpm install
echo "Worktree ready at ../$(basename $PWD), port $NEXT_PORT"
```

```markdown
<!-- tasks/active.md - shared task board -->
# Active Parallel Work

## feat-auth (Alice + claude-1, port 3001)
- Goal: OAuth2 PKCE flow
- Branch: feature/auth
- Files scope: src/auth/**, src/api/auth/**
- Status: GREEN tests, PR pending review

## feat-billing (Bob + claude-2, port 3002)
- Goal: Stripe webhook handler
- Branch: feature/billing
- Files scope: src/billing/**, src/api/webhooks/**
- Status: WIP, 12/18 tasks complete

## hotfix-csv (claude-3, port 3003)
- Goal: fix CSV export memory leak
- Branch: hotfix/csv-export
- Files scope: src/lib/csv/**
- Status: blocked - needs review
```

```yaml
# .claude/hooks/session-start-context.sh - hook che inietta worktree context
#!/usr/bin/env bash
WORKTREE=$(basename "$PWD")
BRANCH=$(git branch --show-current)
PORT=$(grep -oP 'PORT=\K\d+' .env.local 2>/dev/null || echo "3000")
TASK=$(grep -A5 "## $(echo $BRANCH | cut -d/ -f2)" ../tasks/active.md 2>/dev/null || echo "")

cat <<EOF
{
  "additionalContext": "## Current Worktree\nBranch: $BRANCH\nPort: $PORT\nWorktree: $WORKTREE\n\n## Task\n$TASK"
}
EOF
```

**Esempio di sessione tipo**:

```
User (terminal 1, in ../proj-feat-auth):
$ claude
[SessionStart hook: inject worktree context]

Claude: I see I'm working on feature/auth in worktree proj-feat-auth (port 3001).
        Task: OAuth2 PKCE flow. Scope: src/auth/**, src/api/auth/**.
        Ready.

User: implement PKCE code verifier generation
[...]

# Meanwhile in terminal 2, ../proj-feat-billing:
User: implement Stripe webhook idempotency
Claude: [working in feat-billing, port 3002, isolated DB branch]

# No conflicts because file scopes are disjoint.
# Each session has own context, own DB, own dev server.
```

**Metriche di successo**:
- Throughput: 3-5 feature in flight contemporanee (vs 1 sequenziale)
- Zero merge conflict tra worktree (se file scope disjoint)
- Context per session piu focused (ogni agent vede solo il suo scope)
- Test parallel run: 1 suite per worktree, no port collision

**Pitfalls comuni**:
- **`.env` symlink condiviso**: una modifica in un worktree impatta gli altri. Sempre `cp`, mai `ln -s`.
- **Stesso DB per tutti**: write conflict, test pollution. Usa DB branching (Neon/Planetscale) o SQLite locale per worktree.
- **Port hardcoded**: dev server collision. Sempre `PORT=$PORT` env-driven.
- **File scope overlap**: due agent editano lo stesso file = corruzione. Definisci scope ESPLICITO in tasks/active.md.
- **Worktree dimenticati**: 20+ worktree obsoleti consumano disk + confondono. `git worktree prune` settimanale.
- **Context CLAUDE.md inflato**: aggiungere "current task" nel root CLAUDE.md inquina tutte le sessioni. Usa local hook per inject worktree-specific.

**Tooling alternativo**:
- [Worktrunk](https://worktrunk.dev/) - CLI specifico per AI parallel agents
- [agent-worktree](https://github.com/nekocode/agent-worktree) - Git worktree workflow tool con env isolation auto
- VS Code "Multi-Root Workspaces" - aprire piu worktree in singola finestra

**Fonti / Reference reali**:
- [MindStudio - Parallel Agentic Development with Git Worktrees](https://www.mindstudio.ai/blog/parallel-agentic-development-git-worktrees) - playbook completo
- [Augment Code - Git Worktrees for Parallel AI Agent Execution](https://www.augmentcode.com/guides/git-worktrees-parallel-ai-agent-execution) - env isolation pattern
- [agent-interviews - Parallel AI Coding with Git Worktrees](https://docs.agentinterviews.com/blog/parallel-ai-coding-with-gitworktrees/) - custom command setup
- [obra/superpowers using-git-worktrees skill](https://github.com/obra/superpowers) - auto-worktree dopo design approval
- [nrmitchi - Using Git Worktrees for Multi-Feature Development](https://www.nrmitchi.com/2025/10/using-git-worktrees-for-multi-feature-development-with-ai-agents/)
