#!/usr/bin/env bats
# prompt.sh — print a skill's prompts/<name>.txt with its {key} placeholders filled in.

setup() {
  PROMPT="$BATS_TEST_DIRNAME/prompt.sh"
  skill="$BATS_TEST_TMPDIR/skill"
  mkdir -p "$skill/scripts" "$skill/prompts"
  cat > "$skill/scripts/run.sh" <<SH
#!/bin/sh
. "$PROMPT"
prompt "\$@"
SH
}

@test "prints the file as it stands, trailing blank lines included" {
  printf 'Read it.\n\n' > "$skill/prompts/next.txt"
  run sh "$skill/scripts/run.sh" next
  [ "$status" -eq 0 ]
  [ "$output" = "Read it." ]
  [ "$(sh "$skill/scripts/run.sh" next | wc -l | tr -d ' ')" -eq 2 ]
}

@test "replaces every occurrence of each key, values with slashes and quotes included" {
  printf 'Run {cmd} "{file}" then {cmd} again\n' > "$skill/prompts/next.txt"
  run sh "$skill/scripts/run.sh" next cmd='a/b/c.sh' file='story/01 "x".txt'
  [ "$output" = 'Run a/b/c.sh "story/01 "x".txt" then a/b/c.sh again' ]
}

@test "leaves a key with no value given in place" {
  printf 'Run {cmd} on {file}\n' > "$skill/prompts/next.txt"
  run sh "$skill/scripts/run.sh" next cmd=x.sh
  [ "$output" = 'Run x.sh on {file}' ]
}

@test "an empty value removes the key" {
  printf 'split{changed}, go\n' > "$skill/prompts/next.txt"
  run sh "$skill/scripts/run.sh" next changed=
  [ "$output" = 'split, go' ]
}
