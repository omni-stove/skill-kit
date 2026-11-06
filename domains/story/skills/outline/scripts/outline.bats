#!/usr/bin/env bats
# source.sh — the files the outline draws on, the existing story/outline.md, and how to build it.

setup() {
  SOURCE="$BATS_TEST_DIRNAME/source.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work"
  cd "$work" || exit
}

@test "source.sh lists only the header and the steps in an empty repo" {
  run sh "$SOURCE"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "== read ==" ]
  [[ "${lines[1]}" == "Read the files above"* ]]
  [[ "$output" == *"write story/outline.md"* ]]
  [[ "$output" != *"exists:"* ]]
}

@test "source.sh lists the settings, timeline, synopsis and plots in order" {
  mkdir -p characters/main world items story/plot
  : > README.md; : > characters/main/hero.md; : > characters/notes.txt
  : > world/city.md; : > items/key.md
  : > story/timeline.md; : > story/synopsis.txt
  : > story/plot/100-end.md; : > story/plot/020-start.md
  run sh "$SOURCE"
  [ "${lines[1]}" = "README.md" ]
  [ "${lines[2]}" = "characters/main/hero.md" ]
  [ "${lines[3]}" = "world/city.md" ]
  [ "${lines[4]}" = "items/key.md" ]
  [ "${lines[5]}" = "story/timeline.md" ]
  [ "${lines[6]}" = "story/synopsis.txt" ]
  [ "${lines[7]}" = "story/plot/020-start.md" ]
  [ "${lines[8]}" = "story/plot/100-end.md" ]
  [[ "$output" != *"notes.txt"* ]]
}

@test "source.sh lists an existing outline and says to revise it" {
  mkdir -p story
  echo "# 旧" > story/outline.md
  run sh "$SOURCE"
  [ "${lines[1]}" = "story/outline.md" ]
  [[ "${lines[2]}" == "story/outline.md exists: revise it"* ]]
}

@test "source.sh takes no argument" {
  run sh "$SOURCE" extra
  [ "$status" -eq 2 ]
}
