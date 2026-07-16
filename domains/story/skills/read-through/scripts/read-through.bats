#!/usr/bin/env bats
# next.sh / done.sh — progress-tracked sequential reads.

setup() {
  NEXT="$BATS_TEST_DIRNAME/next.sh"
  DONE="$BATS_TEST_DIRNAME/done.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story"
  cd "$work"
}

@test "next.sh prints the first file with its line count" {
  printf 'a\nb\n' > story/01.txt
  printf 'x\n' > story/02.txt
  run sh "$NEXT" story/01.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *"2"* && "$output" == *"01.txt"* ]]
}

@test "next.sh sorts naturally (2 before 10)" {
  : > story/1.txt; : > story/2.txt; : > story/10.txt
  run sh "$NEXT" story/1.txt
  [[ "$output" == *"/1.txt"* ]]
  sh "$DONE" story/1.txt
  run sh "$NEXT" story/1.txt
  [[ "$output" == *"/2.txt"* ]]
  sh "$DONE" story/2.txt
  run sh "$NEXT" story/1.txt
  [[ "$output" == *"/10.txt"* ]]
}

@test "next.sh skips synopsis and dotfiles" {
  : > story/synopsis.txt
  : > story/.hidden
  printf 'body\n' > story/chapter.txt
  run sh "$NEXT" story/chapter.txt
  [[ "$output" == *"chapter.txt"* ]]
}

@test "done.sh advances progress across runs" {
  : > story/a.txt; : > story/b.txt
  sh "$DONE" story/a.txt
  run sh "$NEXT" story/a.txt
  [[ "$output" == *"b.txt"* ]]
}

@test "next.sh prints ALL_DONE and clears state when everything is processed" {
  : > story/only.txt
  sh "$DONE" story/only.txt
  run sh "$NEXT" story/only.txt
  [ "$output" = "ALL_DONE" ]
  # state cleared -> the next run starts over from the first file
  run sh "$NEXT" story/only.txt
  [[ "$output" == *"only.txt"* ]]
}

@test "progress is tracked per directory" {
  mkdir -p other
  : > story/a.txt
  : > other/a.txt
  sh "$DONE" story/a.txt
  run sh "$NEXT" other/a.txt
  [[ "$output" == *"other/a.txt"* ]]
}
