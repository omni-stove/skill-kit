#!/usr/bin/env bats
# llm-instruction-rules.sh — PreToolUse hook: inject house rules when an
# LLM-facing instruction file is written; stay silent otherwise.

setup() {
  # The hook resolves the rules file relative to its deployed location
  # (<repo>/.agents/hooks/ -> <repo>/.agents/refs/), so reproduce that layout.
  repo="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$repo/.agents/hooks" "$repo/.agents/refs"
  cp "$BATS_TEST_DIRNAME/llm-instruction-rules.sh" "$repo/.agents/hooks/"
  echo "THE RULES" > "$repo/.agents/refs/llm-instruction-rules.md"
  HOOK="$repo/.agents/hooks/llm-instruction-rules.sh"
}

hook_with_path() {
  printf '{"tool_input":{"file_path":"%s"}}' "$1" | bash "$HOOK"
}

@test "SKILL.md write injects the rules as additionalContext" {
  run hook_with_path "/somewhere/skills/foo/SKILL.md"
  [ "$status" -eq 0 ]
  [ "$(printf '%s' "$output" | jq -r .hookSpecificOutput.hookEventName)" = "PreToolUse" ]
  [ "$(printf '%s' "$output" | jq -r .hookSpecificOutput.additionalContext)" = "THE RULES" ]
}

@test "CLAUDE.md and AGENTS.md match in any directory" {
  run hook_with_path "/x/CLAUDE.md"
  [ -n "$output" ]
  run hook_with_path "/x/deep/AGENTS.md"
  [ -n "$output" ]
}

@test "files under .claude/commands and .agents/skills match by path" {
  run hook_with_path "/repo/.claude/commands/foo.md"
  [ -n "$output" ]
  run hook_with_path "/repo/.agents/skills/bar/refs.sh"
  [ -n "$output" ]
}

@test "a skill's prompts/*.txt matches in the kit's own tree" {
  run hook_with_path "/kit/domains/story/skills/write/prompts/scene.txt"
  [ -n "$output" ]
  run hook_with_path "/kit/shared/skills/init/prompts/next.txt"
  [ -n "$output" ]
  run hook_with_path "/kit/domains/story/skills/write/scripts/source.sh"
  [ -z "$output" ]
}

@test "an ordinary file exits 0 with no output" {
  run hook_with_path "/repo/src/co/story/01.md"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "input without a path exits 0 with no output" {
  run bash -c 'echo "{}" | bash "$0"' "$HOOK"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "missing rules file exits 0 with no output (never blocks)" {
  rm "$repo/.agents/refs/llm-instruction-rules.md"
  run hook_with_path "/x/SKILL.md"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
