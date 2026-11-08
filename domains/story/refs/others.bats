#!/usr/bin/env bats
# others.sh — the other plot and story files around a source, one per number.

setup() {
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story/plot"
  cd "$work" || exit
}

@test "others.sh prints the story file where a number has both, else the plot file" {
  : > story/plot/010-co-arrival.md
  : > story/010.txt
  : > story/plot/020-night.md
  : > story/plot/030-dawn.md
  : > story/plot/040-end.md
  run sh "$BATS_TEST_DIRNAME/others.sh" story/plot/030-dawn.md
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "story/010.txt" ]
  [ "${lines[1]}" = "story/plot/020-night.md" ]
  [ "${lines[2]}" = "story/plot/040-end.md" ]
  [ "${#lines[@]}" -eq 3 ]
}

@test "others.sh leaves out the source's own pair" {
  : > story/plot/010-co-arrival.md
  : > story/010.txt
  : > story/plot/020-night.md
  : > story/020.txt
  run sh "$BATS_TEST_DIRNAME/others.sh" story/plot/020-night.md
  [ "$output" = "story/010.txt" ]
  run sh "$BATS_TEST_DIRNAME/others.sh" story/020.txt
  [ "$output" = "story/010.txt" ]
}

@test "others.sh --earlier prints only the numbers below the source's" {
  : > story/plot/9-before.md
  : > story/010.txt
  : > story/plot/020-night.md
  : > story/plot/030-dawn.md
  : > story/plot/040-end.md
  : > story/050.txt
  run sh "$BATS_TEST_DIRNAME/others.sh" --earlier story/plot/030-dawn.md
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
  [[ "$output" == *"story/plot/9-before.md"* ]]
  [[ "$output" == *"story/010.txt"* ]]
  [[ "$output" == *"story/plot/020-night.md"* ]]
  [[ "$output" != *040* ]]
  [[ "$output" != *050* ]]
}

@test "others.sh --earlier leaves out files without a number" {
  : > story/plot/prologue.md
  : > story/index.txt
  : > story/plot/010-a.md
  : > story/plot/020-b.md
  run sh "$BATS_TEST_DIRNAME/others.sh" --earlier story/plot/020-b.md
  [ "$output" = "story/plot/010-a.md" ]
  run sh "$BATS_TEST_DIRNAME/others.sh" --earlier story/plot/prologue.md
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "others.sh --earlier works from the story file itself" {
  : > story/010.txt
  : > story/020.txt
  : > story/030.txt
  run sh "$BATS_TEST_DIRNAME/others.sh" --earlier story/020.txt
  [ "$output" = "story/010.txt" ]
}

@test "others.sh fails on a missing source" {
  run sh "$BATS_TEST_DIRNAME/others.sh" story/plot/missing.md
  [ "$status" -eq 1 ]
}
