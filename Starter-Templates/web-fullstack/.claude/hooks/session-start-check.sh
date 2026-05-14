#!/usr/bin/env bash
# SessionStart hook: verifica ambiente pronto.
set -euo pipefail

cd "$CLAUDE_PROJECT_DIR"
warnings=()

[ -d node_modules ] || warnings+=("node_modules mancante — esegui 'pnpm install'")
[ -f .env.local ] || warnings+=(".env.local mancante — copia da .env.example")

if [ -f .env.example ] && [ -f .env.local ]; then
  missing=$(comm -23 \
    <(grep -E '^[A-Z_]+=' .env.example | cut -d= -f1 | sort -u) \
    <(grep -E '^[A-Z_]+=' .env.local  | cut -d= -f1 | sort -u) || true)
  [ -n "$missing" ] && warnings+=("Env vars mancanti in .env.local: $(echo "$missing" | tr '\n' ' ')")
fi

command -v pnpm >/dev/null || warnings+=("pnpm non installato")

if [ ${#warnings[@]} -gt 0 ]; then
  ctx="Environment warnings:\n$(printf -- '- %s\n' "${warnings[@]}")"
  jq -n --arg c "$ctx" '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $c}}'
else
  jq -n '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: "Env OK: deps installate, env vars complete."}}'
fi
