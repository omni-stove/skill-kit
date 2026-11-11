#!/usr/bin/env bash
# PreToolUse hook for Claude Code and Codex: deny reading a skill's script (a .sh under
# .agents/skills/, .agents/refs/ or .claude/skills/), so the model runs it as the skill says
# instead of opening it first. A Read counts, and so does any tool call whose
# tool_input.command (a string, or an argv array, either maybe wrapped in sh -c) starts its first segment with a file
# viewer naming such a script — whatever the shell tool is called. Anything else passes
# through with no output.
set -euo pipefail

input="$(cat)"
tool="$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null || true)"

is_script() {
  case "$1" in
    .agents/skills/*.sh | */.agents/skills/*.sh | .agents/refs/*.sh | */.agents/refs/*.sh | \
      .claude/skills/*.sh | */.claude/skills/*.sh) return 0 ;;
  esac
  return 1
}

script=
case "$tool" in
  Read)
    path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)"
    is_script "$path" && script="$path"
    ;;
  *)
    cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty
      | if type == "array" then (if (.[0] // "" | test("(^|/)(ba|z)?sh$")) and (.[1] // "" | test("^-l?c$")) then .[2] // "" else join(" ") end)
        else tostring end' 2>/dev/null || true)"
    # A string that wraps the command in sh -c, as Codex sends it.
    cmd="$(printf '%s' "$cmd" | sed -E "s/^[[:space:]]*([^[:space:]]*\/)?(ba|z)?sh -l?c [\"']?//")"
    first="${cmd%%[|;&<>]*}"
    read -r -a words <<<"$first" || true
    case "${words[0]:-}" in
      cat | head | tail | sed | less | more | bat | nl | awk | view)
        for w in "${words[@]:1}"; do
          w="${w#[\"\']}"
          w="${w%[\"\']}"
          if is_script "$w"; then script="$w"; break; fi
        done
        ;;
    esac
    ;;
esac
[ -n "$script" ] || exit 0

jq -n --arg s "$script" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: ("Run `" + $s + "` with the arguments the skill gives instead of reading it. Its output says what to do next; a failed run says how to fix it.")
  }
}'
