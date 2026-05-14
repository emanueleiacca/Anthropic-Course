#!/usr/bin/env bash
# PostToolUse hook: formatta/lintea file modificati da Edit|Write.
set -euo pipefail

payload="$(cat)"
tool="$(printf '%s' "$payload" | jq -r '.tool_name // empty')"
file="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')"

case "$tool" in
  Edit|Write|MultiEdit) ;;
  *) exit 0 ;;
esac

[ -n "$file" ] && [ -f "$file" ] || exit 0

case "$file" in
  "$CLAUDE_PROJECT_DIR"/*) ;;
  *) exit 0 ;;
esac

cd "$CLAUDE_PROJECT_DIR"

case "$file" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.json|*.md|*.css)
    pnpm exec prettier --write --log-level warn "$file" >&2 || true
    case "$file" in
      *.ts|*.tsx|*.js|*.jsx)
        pnpm exec eslint --fix --quiet "$file" >&2 || true
        ;;
    esac
    ;;
  *.sql)
    command -v sqlfluff >/dev/null && sqlfluff fix --dialect postgres "$file" >&2 || true
    ;;
esac

exit 0
