#!/usr/bin/env bats
# before-skill.sh — PreToolUse hook on Skill: the given command runs before the named skill
# and its failure denies the skill; other skills pass through silently.

setup() {
  HOOK="$BATS_TEST_DIRNAME/before-skill.sh"
  CALLS="$BATS_TEST_TMPDIR/calls"
  CODE="$BATS_TEST_TMPDIR/code" # the command's exit code
  : > "$CALLS"; echo 0 > "$CODE"
  cat > "$BATS_TEST_TMPDIR/check" <<STUB
#!/usr/bin/env bash
echo "check \$*" >> "$CALLS"
echo "✗ lint (exit 1)"
echo "src/a.ts:3:1 lint error" >&2
exit "\$(cat "$CODE")"
STUB
  chmod +x "$BATS_TEST_TMPDIR/check"
  PATH="$BATS_TEST_TMPDIR:$PATH"
}

hook_for_skill() {
  printf '{"tool_name":"Skill","tool_input":{"skill":"%s","args":""}}' "$1" | bash "$HOOK" pr check --all
}

@test "another skill passes through without running the command" {
  run hook_for_skill next-task
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [ ! -s "$CALLS" ]
}

@test "a passing command lets the skill run" {
  run hook_for_skill pr
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [ "$(cat "$CALLS")" = "check --all" ]
}

@test "a failing command denies the skill with its output as the reason" {
  echo 1 > "$CODE"
  run hook_for_skill pr
  [ "$status" -eq 0 ]
  [ "$(printf '%s' "$output" | jq -r .hookSpecificOutput.permissionDecision)" = "deny" ]
  reason="$(printf '%s' "$output" | jq -r .hookSpecificOutput.permissionDecisionReason)"
  [[ "$reason" == *'`check --all` failed'* ]]
  [[ "$reason" == *"invoke the pr skill again"* ]]
  [[ "$reason" == *"✗ lint (exit 1)"* ]]
  [[ "$reason" == *"src/a.ts:3:1 lint error"* ]]
}

@test "malformed input passes through" {
  run bash -c "echo 'not json' | bash '$HOOK' pr check"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "needs a skill and a command" {
  run bash "$HOOK" pr
  [ "$status" -eq 2 ]
}
