#!/usr/bin/env bats
# source.sh — the files the 梗概 draws on; save.sh — the normalized 梗概 written to story/synopsis.txt.

setup() {
  SOURCE="$BATS_TEST_DIRNAME/source.sh"
  SAVE="$BATS_TEST_DIRNAME/save.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/characters/main" "$work/story"
  cd "$work"
}

@test "source.sh lists README.md and the character files, and says to draft" {
  : > README.md
  : > characters/main/hero.md
  : > characters/notes.txt
  run sh "$SOURCE"
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "README.md" ]
  [ "${lines[2]}" = "characters/main/hero.md" ]
  [[ "$output" != *"notes.txt"* ]]
  [[ "$output" != *"revise it"* ]]
  [[ "$output" == *"AskUserQuestion"* && "$output" == *"save.sh"* ]]
}

@test "source.sh points at an existing synopsis to revise" {
  echo old > story/synopsis.txt
  run sh "$SOURCE"
  [[ "$output" == *"story/synopsis.txt exists: revise it"* ]]
}

@test "save.sh strips blank lines and leading spaces and prints the path" {
  run sh "$SAVE" <<< "$(printf '　一行目。\n\n  二行目。\n')"
  [ "$status" -eq 0 ]
  [ "$output" = "story/synopsis.txt" ]
  [ "$(cat story/synopsis.txt)" = "$(printf '一行目。\n二行目。')" ]
}

@test "save.sh rejects an empty body" {
  run sh "$SAVE" < /dev/null
  [ "$status" -eq 1 ]
  [ ! -e story/synopsis.txt ]
}
