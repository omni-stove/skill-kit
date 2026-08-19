#!/usr/bin/env bats
# pairs.sh — deterministic file list with adjacency for cross-file checks.

setup() {
  PAIRS="$BATS_TEST_DIRNAME/pairs.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story"
  cd "$work"
}

@test "pairs.sh pairs each file with the next in natural order, last with -" {
  : > story/1.txt; : > story/2.txt; : > story/10.txt
  run sh "$PAIRS" story
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "$(printf 'story/1.txt\tstory/2.txt')" ]
  [ "${lines[1]}" = "$(printf 'story/2.txt\tstory/10.txt')" ]
  [ "${lines[2]}" = "$(printf 'story/10.txt\t-')" ]
  [ "${#lines[@]}" -eq 3 ]
}

@test "pairs.sh accepts a file inside the directory" {
  : > story/a.txt; : > story/b.txt
  run sh "$PAIRS" story/b.txt
  [ "${lines[0]}" = "$(printf 'story/a.txt\tstory/b.txt')" ]
}

@test "pairs.sh skips synopsis, dotfiles and non-txt files" {
  : > story/synopsis.txt; : > story/.hidden.txt; : > story/notes.md; : > story/only.txt
  run sh "$PAIRS" story
  [ "$output" = "$(printf 'story/only.txt\t-')" ]
}

@test "pairs.sh prints nothing for an empty directory" {
  run sh "$PAIRS" story
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "pairs.sh fails on a missing path" {
  run sh "$PAIRS" nope
  [ "$status" -ne 0 ]
}
