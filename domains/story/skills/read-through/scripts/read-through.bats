#!/usr/bin/env bats
# next.sh / done.sh — progress-tracked sequential reads.

setup() {
  NEXT="$BATS_TEST_DIRNAME/next.sh"
  DONE="$BATS_TEST_DIRNAME/done.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story"
  cd "$work"
}

mark_done() { echo "impression of $1" | sh "$DONE" "$1"; }

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
  mark_done story/1.txt
  run sh "$NEXT" story/1.txt
  [[ "$output" == *"/2.txt"* ]]
  mark_done story/2.txt
  run sh "$NEXT" story/1.txt
  [[ "$output" == *"/10.txt"* ]]
}

@test "next.sh skips synopsis and dotfiles" {
  : > story/synopsis.txt
  : > story/.hidden.txt
  printf 'body\n' > story/chapter.txt
  run sh "$NEXT" story/chapter.txt
  [[ "$output" == *"chapter.txt"* ]]
}

@test "next.sh only picks up txt files" {
  : > story/notes.md
  : > story/cover.png
  printf 'body\n' > story/chapter.txt
  run sh "$NEXT" story/chapter.txt
  [[ "$output" == *"chapter.txt"* ]]
  mark_done story/chapter.txt
  run sh "$NEXT" story/chapter.txt
  [ "$output" = "ALL_DONE" ]
}

@test "done.sh advances progress across runs" {
  : > story/a.txt; : > story/b.txt
  mark_done story/a.txt
  run sh "$NEXT" story/a.txt
  [[ "$output" == *"b.txt"* ]]
}

@test "done.sh rejects an empty impression and records nothing" {
  : > story/a.txt
  run sh "$DONE" story/a.txt < /dev/null
  [ "$status" -ne 0 ]
  run sh "$NEXT" story/a.txt
  [[ "$output" == *"a.txt"* ]]
}

@test "done.sh appends the impression to the run's record" {
  : > story/a.txt; : > story/b.txt
  echo "solid opening" | sh "$DONE" story/a.txt
  echo "weaker middle" | sh "$DONE" story/b.txt
  record=$(find out/read-through -name '*.impressions.md')
  grep -q "solid opening" "$record"
  grep -q "weaker middle" "$record"
  grep -q "## a.txt" "$record"
}

@test "a fresh run drops the previous run's impressions record" {
  : > story/only.txt
  echo "old take" | sh "$DONE" story/only.txt
  sh "$NEXT" story/only.txt
  run sh "$NEXT" story/only.txt
  [[ "$output" == *"only.txt"* ]]
  record=$(find out/read-through -name '*.impressions.md')
  ! grep -q "old take" "$record"
}

@test "next.sh prints ALL_DONE and clears state when everything is processed" {
  : > story/only.txt
  mark_done story/only.txt
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
  mark_done story/a.txt
  run sh "$NEXT" other/a.txt
  [[ "$output" == *"other/a.txt"* ]]
}
