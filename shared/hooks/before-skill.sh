#!/usr/bin/env bash
# PreToolUse hook on Skill: run a command before the named skill and deny the skill with the
# command's output when it fails. Which skill and which command are the registering repo's
# call, given as the hook's arguments in .claude/settings.json; any other skill passes
# through with no output.
# usage: before-skill.sh <skill> <command> [arg]...
set -euo pipefail

[ "$#" -ge 2 ] || { echo "usage: before-skill.sh <skill> <command> [arg]..." >&2; exit 2; }
want="$1"
shift

input="$(cat)"
skill="$(printf '%s' "$input" | jq -r '.tool_input.skill // .tool_input.name // empty' 2>/dev/null || true)"
[ "$skill" = "$want" ] || exit 0

# The output goes whole into the reason: the model fixes from it without rerunning the command.
if out="$("$@" 2>&1)"; then
  exit 0
fi
jq -n --arg cmd "$*" --arg skill "$want" --arg out "$out" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: ("`" + $cmd + "` failed, so the " + $skill + " skill did not run. Fix the failures below, then invoke the " + $skill + " skill again.\n\n" + $out)
  }
}'
