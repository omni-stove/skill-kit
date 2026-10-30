#!/usr/bin/env bats
# next.sh / done.sh / summary.sh — progress-tracked sequential reads.

setup() {
  NEXT="$BATS_TEST_DIRNAME/next.sh"
  DONE="$BATS_TEST_DIRNAME/done.sh"
  SUMMARY="$BATS_TEST_DIRNAME/summary.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story"
  cd "$work" || exit
}

mark_done() { printf 'impression of %s\nsecond line\nthird line\n' "$1" | sh "$DONE" "$1"; }

@test "next.sh prints the first file with its line count" {
  printf 'a\nb\n' > story/01.txt
  printf 'x\n' > story/02.txt
  run sh "$NEXT" story/01.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *"2"* && "$output" == *"01.txt"* ]]
}

@test "next.sh accepts a file:// URL, percent-encoded or with a host" {
  mkdir -p "story/第 1章"
  printf 'body\n' > "story/第 1章/a.txt"
  run sh "$NEXT" "file://$PWD/story/%E7%AC%AC%201%E7%AB%A0/a.txt"
  [ "$status" -eq 0 ]
  [[ "$output" == *"第 1章/a.txt"* && "$output" == *"done.sh"* ]]
  mark_done "story/第 1章/a.txt"
  run sh "$NEXT" "file://localhost$PWD/story/%E7%AC%AC%201%E7%AB%A0/a.txt"
  [[ "$output" == ALL_DONE* ]]
  [[ "$output" == *"summary.sh \"$PWD/story/第 1章/a.txt\""* ]]
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
  [[ "$output" == ALL_DONE* ]]
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

@test "done.sh appends the impression to the run's record and points at next.sh" {
  : > story/a.txt; : > story/b.txt
  run mark_done story/a.txt
  [[ "$output" == *"next.sh \"story/a.txt\""* ]]
  record=$(echo out/read-through/*.impressions.md)
  mark_done story/b.txt
  grep -q "impression of story/a.txt" "$record"
  grep -q "impression of story/b.txt" "$record"
  grep -q "## a.txt" "$record"
}

@test "a fresh run discards the previous run's impressions" {
  : > story/only.txt
  printf 'old take\nline two\nline three\n' | sh "$DONE" story/only.txt
  sh "$NEXT" story/only.txt
  run sh "$NEXT" story/only.txt
  [[ "$output" == *"only.txt"* ]]
  mark_done story/only.txt
  record=$(echo out/read-through/*.impressions.md)
  ! grep -q "old take" "$record" || false
  grep -q "impression of story/only.txt" "$record"
  # shellcheck disable=SC2012 # the glob names only files the test made
  [ "$(ls out/read-through/*.impressions.md | wc -l)" -eq 1 ]
}

@test "next.sh prints ALL_DONE, clears state, and forgets the last impression" {
  : > story/only.txt
  mark_done story/only.txt
  run sh "$NEXT" story/only.txt
  [[ "$output" == ALL_DONE* ]]
  # state cleared -> the next run starts over and may reuse the same impression
  run sh "$NEXT" story/only.txt
  [[ "$output" == *"only.txt"* ]]
  mark_done story/only.txt
}

@test "summary.sh appends the summary to the same record and prints its path" {
  : > story/a.txt
  mark_done story/a.txt
  sh "$NEXT" story/a.txt
  run sh "$SUMMARY" story/a.txt < <(printf 'overall take\n')
  [ "$status" -eq 0 ]
  record="${lines[0]}"
  [[ "${lines[1]}" == *"Output that record path"* ]]
  [[ "$record" == *".impressions.md" ]]
  grep -q "impression of story/a.txt" "$record"
  grep -q "## Overall Summary" "$record"
  grep -q "overall take" "$record"
  # shellcheck disable=SC2012 # the glob names only files the test made
  [ "$(ls out/read-through/* | wc -l)" -eq 1 ]
}

@test "summary.sh rejects an empty summary and writes nothing" {
  : > story/a.txt
  mark_done story/a.txt
  sh "$NEXT" story/a.txt
  run sh "$SUMMARY" story/a.txt < /dev/null
  [ "$status" -ne 0 ]
  ! grep -q "Overall Summary" out/read-through/*.impressions.md || false
}

@test "progress is tracked per directory" {
  mkdir -p other
  : > story/a.txt
  : > other/a.txt
  mark_done story/a.txt
  run sh "$NEXT" other/a.txt
  [[ "$output" == *"other/a.txt"* ]]
}

@test "next.sh prints the read and done.sh action for the file" {
  printf 'body\n' > story/a.txt
  run sh "$NEXT" story/a.txt
  [[ "$output" == *"a.txt"* ]]
  [[ "$output" == *"Read that file whole into context"* ]]
  [[ "$output" == *"done.sh"* ]]
}

@test "next.sh prints the summary.sh action alongside ALL_DONE" {
  : > story/a.txt
  mark_done story/a.txt
  run sh "$NEXT" story/a.txt
  [[ "$output" == ALL_DONE* ]]
  [[ "$output" == *"summary.sh"* ]]
}
