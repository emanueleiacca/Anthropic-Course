#!/usr/bin/env bash
# PreToolUse hook: blocca comandi distruttivi anche se sfuggono ai permission rules.
set -euo pipefail

payload="$(cat)"
tool="$(printf '%s' "$payload" | jq -r '.tool_name // empty')"

[ "$tool" = "Bash" ] || exit 0

cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty')"

deny_patterns=(
  'rm[[:space:]]+-rf[[:space:]]+/'
  'rm[[:space:]]+-rf[[:space:]]+\*'
  'rm[[:space:]]+-rf[[:space:]]+~'
  'git[[:space:]]+push[[:space:]]+.*--force'
  'git[[:space:]]+push[[:space:]]+.*-f([[:space:]]|$)'
  'git[[:space:]]+reset[[:space:]]+--hard[[:space:]]+origin'
  'DROP[[:space:]]+(TABLE|DATABASE|SCHEMA)'
  'TRUNCATE[[:space:]]+TABLE'
  'chmod[[:space:]]+777'
  'curl[[:space:]]+.*\|[[:space:]]*(bash|sh)'
)

for pat in "${deny_patterns[@]}"; do
  if printf '%s' "$cmd" | grep -E -q -- "$pat"; then
    echo "BLOCKED: comando corrisponde a pattern proibito ($pat). Comando: $cmd" >&2
    exit 2
  fi
done

exit 0
