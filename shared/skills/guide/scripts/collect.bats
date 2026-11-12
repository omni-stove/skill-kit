#!/usr/bin/env bats
# guide collect.sh — the synced domain's flow, then each installed skill but guide.

bats_require_minimum_version 1.5.0

setup() {
  COLLECT="$BATS_TEST_DIRNAME/collect.sh"
  cd "$BATS_TEST_TMPDIR"
  mkdir -p .agents/refs .agents/skills/run .agents/skills/guide .agents/skills/notes
  printf -- '---\nname: run\ndescription: Build and run the game.\n---\n\nbody\n' > .agents/skills/run/SKILL.md
  printf -- '---\nname: guide\ndescription: Tell the user which skill.\n---\n' > .agents/skills/guide/SKILL.md
  printf 'no frontmatter\nname: x\n' > .agents/skills/notes/SKILL.md
}

@test "prints the domain flow, then each skill but guide, then what to do" {
  echo game > .agents/refs/domain
  run "$COLLECT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "# game flow" ]
  [ "${lines[1]}" = '```mermaid' ]
  [[ "$output" == *"post-mortem"* ]]
  [[ "$output" == *$'run\tBuild and run the game.'* ]]
  [[ "$output" != *$'guide\t'* ]]
  [[ "$output" != *$'x\t'* ]]
  [[ "$output" == *"Answer what the user asked"* ]]
}

@test "without a recorded domain, prints the skills alone" {
  run "$COLLECT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "# skills" ]
}

@test "outside a synced repo, says where to run it" {
  rm -r .agents
  run "$COLLECT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"skill-kit <domain> sync"* ]]
}
