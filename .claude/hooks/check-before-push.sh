#!/usr/bin/env bash
# PreToolUse (Skill) / UserPromptSubmit hook for this repo: before cap or pr runs, run make lint
# and make test, and have the model fix what fails before the skill goes on.
set -euo pipefail

input="$(cat)"
event="$(printf '%s' "$input" | jq -r '.hook_event_name')"
case "$event" in
  PreToolUse) printf '%s' "$input" | jq -r '.tool_input.skill // empty' | grep -qxE 'cap|pr' || exit 0 ;;
  UserPromptSubmit) printf '%s' "$input" | jq -r '.prompt // empty' | grep -qE '^/(cap|pr)([[:space:]]|$)' || exit 0 ;;
  *) exit 0 ;;
esac

cd "$CLAUDE_PROJECT_DIR"
out="$({ make lint && make test; } 2>&1)" && exit 0
msg="$(printf '%s\n\nmake lint / make test failed: fix the failures above before pushing.' "$out")"
# A typed /cap or /pr is not blocked, which would drop the prompt: the failure goes to the model
# as context instead, so it fixes first either way.
[ "$event" = UserPromptSubmit ] && { printf '%s\n' "$msg"; exit 0; }
printf '%s\n' "$msg" >&2
exit 2
