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

@test "path.sh numbers a new plot 010 in an empty or missing story/plot/" {
  run sh "$PATHSH" first-contact
  [ "$status" -eq 0 ]
  [ "$output" = "Output: story/plot/010-first-contact.md" ]
}

@test "path.sh numbers a new plot at the next ten after the highest number" {
  mkdir -p story/plot
  : > story/plot/010-arrival.md; : > story/plot/085-detour.md; : > story/plot/memo.md
  run sh "$PATHSH" return
  [ "${lines[0]}" = "Output: story/plot/090-return.md" ]
  : > story/plot/090-return.md
  run sh "$PATHSH" epilogue
  [ "${lines[0]}" = "Output: story/plot/100-epilogue.md" ]
}

@test "path.sh says to confirm the overwrite when the plot exists, numbered or not" {
  mkdir -p story/plot
  : > story/plot/020-first-contact.md; : > story/plot/memo.md
  run sh "$PATHSH" first-contact
  [ "${lines[0]}" = "Output: story/plot/020-first-contact.md" ]
  [[ "$output" == *"Confirm the overwrite"* ]]
  run sh "$PATHSH" memo
  [ "${lines[0]}" = "Output: story/plot/memo.md" ]
  [[ "$output" == *"Confirm the overwrite"* ]]
}

@test "path.sh does not take a longer slug ending in the same words for the plot" {
  mkdir -p story/plot
  : > story/plot/010-the-first-contact.md
  run sh "$PATHSH" first-contact
  [ "${lines[0]}" = "Output: story/plot/020-first-contact.md" ]
}

@test "path.sh rejects a slug that is not kebab-case or starts with a number" {
  run sh "$PATHSH" "First Contact"
  [ "$status" -eq 1 ]
  run sh "$PATHSH" 010-first-contact
  [ "$status" -eq 1 ]
}
