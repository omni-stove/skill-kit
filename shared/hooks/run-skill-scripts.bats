#!/usr/bin/env bats
# run-skill-scripts.sh — PreToolUse hook on Read|Bash: reading a skill's script is denied
# with the step to run it; anything else passes through silently.

setup() {
  HOOK="$BATS_TEST_DIRNAME/run-skill-scripts.sh"
}

read_file() {
  jq -n --arg p "$1" '{tool_name: "Read", tool_input: {file_path: $p}}' | bash "$HOOK"
}

bash_cmd() {
  jq -n --arg c "$1" '{tool_name: "Bash", tool_input: {command: $c}}' | bash "$HOOK"
}

denied() {
  [ "$status" -eq 0 ]
  [ "$(printf '%s' "$output" | jq -r .hookSpecificOutput.permissionDecision)" = "deny" ]
  [[ "$(printf '%s' "$output" | jq -r .hookSpecificOutput.permissionDecisionReason)" == "Run \`$1\`"* ]]
}

passed() {
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "reading a skill's script, refs.sh or a shared ref script is denied" {
  run read_file /repo/.agents/skills/write/scripts/source.sh
  denied /repo/.agents/skills/write/scripts/source.sh
  run read_file /repo/.agents/skills/write/refs.sh
  denied /repo/.agents/skills/write/refs.sh
  run read_file /repo/.agents/refs/others.sh
  denied /repo/.agents/refs/others.sh
  run read_file /repo/.claude/skills/write/scripts/source.sh
  denied /repo/.claude/skills/write/scripts/source.sh
}

@test "reading other files passes" {
  run read_file /repo/.agents/skills/write/SKILL.md
  passed
  run read_file /repo/.agents/hooks/before-skill.sh
  passed
  run read_file /repo/domains/story/skills/write/scripts/source.sh
  passed
}

@test "a viewer command on a script is denied" {
  run bash_cmd "cat .agents/skills/write/scripts/source.sh"
  denied .agents/skills/write/scripts/source.sh
  run bash_cmd "sed -n '1,40p' '.agents/refs/others.sh' | head"
  denied .agents/refs/others.sh
}

@test "running a script passes, with stdin from a viewer too" {
  run bash_cmd ".agents/skills/write/scripts/source.sh plot/01.md"
  passed
  run bash_cmd "cat report.md | .agents/skills/staging/scripts/save.sh a.txt"
  passed
  run bash_cmd "cat"
  passed
}

@test "a shell tool under another name, or with an argv array, is checked too" {
  run bash -c "jq -n '{tool_name: \"shell\", tool_input: {command: \"cat .agents/refs/others.sh\"}}' | bash '$HOOK'"
  denied .agents/refs/others.sh
  run bash -c "jq -n '{tool_name: \"shell\", tool_input: {command: [\"sed\", \"-n\", \"1,9p\", \".agents/refs/others.sh\"]}}' | bash '$HOOK'"
  denied .agents/refs/others.sh
  run bash -c "jq -n '{tool_name: \"shell\", tool_input: {command: [\"bash\", \"-lc\", \"cat .agents/refs/others.sh\"]}}' | bash '$HOOK'"
  denied .agents/refs/others.sh
  run bash_cmd "/bin/zsh -lc 'head .agents/refs/others.sh'"
  denied .agents/refs/others.sh
  run bash -c "jq -n '{tool_name: \"shell\", tool_input: {command: [\"bash\", \"-lc\", \".agents/refs/others.sh a.txt\"]}}' | bash '$HOOK'"
  passed
}

@test "other tools and malformed input pass" {
  run bash -c "jq -n '{tool_name: \"Edit\", tool_input: {file_path: \"/r/.agents/refs/x.sh\"}}' | bash '$HOOK'"
  passed
  run bash -c "echo 'not json' | bash '$HOOK'"
  passed
}
