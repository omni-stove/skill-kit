#!/usr/bin/env bats
# path.sh — deterministic listing of story/plot/ and resolution of a plot's output path.

setup() {
  PATHSH="$BATS_TEST_DIRNAME/path.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work"
  cd "$work"
}

@test "path.sh prints nothing when story/plot/ is missing" {
  run sh "$PATHSH"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "path.sh lists the plot files in natural sort order" {
  mkdir -p story/plot
  : > story/plot/b.md; : > story/plot/a.md; : > story/plot/notes.txt
  run sh "$PATHSH"
  [ "${lines[0]}" = "story/plot/a.md" ]
  [ "${lines[1]}" = "story/plot/b.md" ]
  [ "${#lines[@]}" -eq 2 ]
}

@test "path.sh resolves a slug under story/plot/" {
  run sh "$PATHSH" first-contact
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Output: story/plot/first-contact.md" ]
  [[ "$output" == *"does not exist yet"* ]]
}

@test "path.sh says to confirm the overwrite when the plot exists" {
  mkdir -p story/plot
  : > story/plot/first-contact.md
  run sh "$PATHSH" first-contact
  [[ "$output" == *"Confirm the overwrite"* ]]
}

@test "path.sh rejects a slug that is not kebab-case or starts with a number" {
  run sh "$PATHSH" "First Contact"
  [ "$status" -eq 1 ]
  run sh "$PATHSH" 010-first-contact
  [ "$status" -eq 1 ]
}
