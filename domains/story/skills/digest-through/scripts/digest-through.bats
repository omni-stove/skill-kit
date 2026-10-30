#!/usr/bin/env bats
# next.sh / done.sh / summary.sh — progress-tracked sequential digests.

setup() {
  NEXT="$BATS_TEST_DIRNAME/next.sh"
  DONE="$BATS_TEST_DIRNAME/done.sh"
  SUMMARY="$BATS_TEST_DIRNAME/summary.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story"
  cd "$work" || exit
}

mark_done() { printf 'digest of %s\n' "$1" | sh "$DONE" "$1"; }

@test "next.sh prints the first file with its line count and the action" {
  printf 'a\nb\n' > story/01.txt
  printf 'x\n' > story/02.txt
  run sh "$NEXT" story/01.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *"2"* && "$output" == *"01.txt"* ]]
  [[ "$output" == *"Read that file whole into context"* ]]
  [[ "$output" == *"done.sh"* ]]
  [[ "$output" == *"who, what happens, and the ending state"* ]]
}

@test "next.sh accepts the directory itself" {
  printf 'a\n' > story/01.txt
  run sh "$NEXT" story
  [[ "$output" == *"01.txt"* ]]
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

@test "next.sh skips synopsis, dotfiles and non-txt files" {
  : > story/synopsis.txt
  : > story/.hidden.txt
  : > story/notes.md
  printf 'body\n' > story/chapter.txt
  run sh "$NEXT" story/chapter.txt
  [[ "$output" == *"chapter.txt"* ]]
  mark_done story/chapter.txt
  run sh "$NEXT" story/chapter.txt
  [[ "$output" == ALL_DONE* ]]
  [[ "$output" == *"summary.sh"* ]]
}

@test "done.sh advances progress across runs" {
  : > story/a.txt; : > story/b.txt
  mark_done story/a.txt
  run sh "$NEXT" story/a.txt
  [[ "$output" == *"b.txt"* ]]
}

@test "done.sh rejects an empty digest and records nothing" {
  : > story/a.txt
  run sh "$DONE" story/a.txt < /dev/null
  [ "$status" -ne 0 ]
  run sh "$NEXT" story/a.txt
  [[ "$output" == *"a.txt"* ]]
}

@test "done.sh appends the digest to the run's record and points at next.sh" {
  : > story/a.txt; : > story/b.txt
  run mark_done story/a.txt
  [[ "$output" == *"next.sh \"story/a.txt\""* ]]
  record=$(echo out/digest-through/*.md)
  mark_done story/b.txt
  grep -q "digest of story/a.txt" "$record"
  grep -q "digest of story/b.txt" "$record"
  grep -q "## a.txt" "$record"
}

@test "a fresh run discards the previous run's digests" {
  : > story/only.txt
  printf 'old take\n' | sh "$DONE" story/only.txt
  sh "$NEXT" story/only.txt
  run sh "$NEXT" story/only.txt
  [[ "$output" == *"only.txt"* ]]
  mark_done story/only.txt
  record=$(echo out/digest-through/*.md)
  ! grep -q "old take" "$record" || false
  grep -q "digest of story/only.txt" "$record"
}

@test "next.sh prints ALL_DONE and clears state" {
  : > story/only.txt
  mark_done story/only.txt
  run sh "$NEXT" story/only.txt
  [[ "$output" == ALL_DONE* ]]
  run sh "$NEXT" story/only.txt
  [[ "$output" == *"only.txt"* ]]
}

@test "summary.sh appends the overall understanding to the same record" {
  : > story/a.txt
  mark_done story/a.txt
  sh "$NEXT" story/a.txt
  run sh "$SUMMARY" story < <(printf 'overall take\n')
  [ "$status" -eq 0 ]
  record="${lines[0]}"
  [[ "${lines[1]}" == *"Output that record path"* ]]
  grep -q "digest of story/a.txt" "$record"
  grep -q "## Overall" "$record"
  grep -q "overall take" "$record"
}

@test "summary.sh rejects an empty summary and writes nothing" {
  : > story/a.txt
  mark_done story/a.txt
  sh "$NEXT" story/a.txt
  run sh "$SUMMARY" story < /dev/null
  [ "$status" -ne 0 ]
  ! grep -q "Overall" out/digest-through/*.md || false
}

@test "progress is tracked per directory" {
  mkdir -p other
  : > story/a.txt
  : > other/a.txt
  mark_done story/a.txt
  run sh "$NEXT" other/a.txt
  [[ "$output" == *"other/a.txt"* ]]
}
