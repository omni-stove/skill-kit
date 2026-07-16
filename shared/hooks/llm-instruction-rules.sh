#!/usr/bin/env bash
# PreToolUse hook: when an LLM-facing instruction file is about to be written/edited,
# inject the house rules for writing such files as additionalContext.
# Never blocks — only adds context. Exits 0 with no output for non-matching paths.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
rules_file="$here/../../.agents/refs/llm-instruction-rules.md"

input="$(cat)"

path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || true)"
[ -z "$path" ] && exit 0

base="$(basename "$path")"

# Match LLM-facing instruction files:
#   SKILL.md / AGENTS.md / CLAUDE.md (any dir)
#   anything under .claude/commands/ or .agents/skills/
#   workflow defs under .claude/workflows/
case "$base:$path" in
  SKILL.md:*|AGENTS.md:*|CLAUDE.md:*) match=1 ;;
  *:*/.claude/commands/*|*:*/.agents/skills/*|*:*/.claude/workflows/*) match=1 ;;
  *) match=0 ;;
esac
[ "$match" -eq 0 ] && exit 0
[ -f "$rules_file" ] || exit 0

rules="$(cat "$rules_file")"
jq -n --arg ctx "$rules" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    additionalContext: $ctx
  }
}'
