#!/usr/bin/env bats
# next.sh / done.sh — progress-tracked sequential reads.

setup() {
  NEXT="$BATS_TEST_DIRNAME/next.sh"
  DONE="$BATS_TEST_DIRNAME/done.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story"
  cd "$work"
}

mark_done() { printf 'impression of %s\nsecond line\nthird line\n' "$1" | sh "$DONE" "$1"; }

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

@test "done.sh rejects an impression under 3 lines and records nothing" {
  : > story/a.txt
  run sh "$DONE" story/a.txt < /dev/null
  [ "$status" -ne 0 ]
  printf 'one line\n' > imp
  run sh "$DONE" story/a.txt < imp
  [ "$status" -ne 0 ]
  run sh "$NEXT" story/a.txt
  [[ "$output" == *"a.txt"* ]]
}

@test "done.sh rejects an impression copied from the previous file" {
  : > story/a.txt; : > story/b.txt
  printf 'same\nsame\nsame\n' | sh "$DONE" story/a.txt
  run sh "$DONE" story/b.txt < <(printf 'same\nsame\nsame\n')
  [ "$status" -ne 0 ]
  run sh "$NEXT" story/a.txt
  [[ "$output" == *"b.txt"* ]]
}

@test "done.sh appends the impression to the run's record and prints its path" {
  : > story/a.txt; : > story/b.txt
  run mark_done story/a.txt
  record="$output"
  [[ "$record" == *".impressions.md" ]]
  mark_done story/b.txt
  grep -q "impression of story/a.txt" "$record"
  grep -q "impression of story/b.txt" "$record"
  grep -q "## a.txt" "$record"
}

@test "the record path carries a timestamp" {
  : > story/a.txt
  run mark_done story/a.txt
  [[ "$output" =~ -[0-9]{10,}\.impressions\.md$ ]]
}

@test "a fresh run opens a new record and keeps the previous run's" {
  : > story/only.txt
  printf 'old take\nline two\nline three\n' | sh "$DONE" story/only.txt
  old=$(cat out/read-through/*.record)
  sh "$NEXT" story/only.txt
  sleep 1
  run sh "$NEXT" story/only.txt
  [[ "$output" == *"only.txt"* ]]
  run mark_done story/only.txt
  [ "$output" != "$old" ]
  ! grep -q "old take" "$output"
  grep -q "old take" "$old"
}

@test "next.sh prints ALL_DONE, clears state, and forgets the last impression" {
  : > story/only.txt
  mark_done story/only.txt
  run sh "$NEXT" story/only.txt
  [ "$output" = "ALL_DONE" ]
  # state cleared -> the next run starts over and may reuse the same impression
  run sh "$NEXT" story/only.txt
  [[ "$output" == *"only.txt"* ]]
  mark_done story/only.txt
}

@test "progress is tracked per directory" {
  mkdir -p other
  : > story/a.txt
  : > other/a.txt
  mark_done story/a.txt
  run sh "$NEXT" other/a.txt
  [[ "$output" == *"other/a.txt"* ]]
}
