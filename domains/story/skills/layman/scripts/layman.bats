#!/usr/bin/env bats
# files.sh — the evaluation target list.

setup() {
  FILES="$BATS_TEST_DIRNAME/files.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story"
  cd "$work"
}

@test "files.sh lists a directory's txt files in natural order" {
  : > story/1.txt; : > story/2.txt; : > story/10.txt
  run sh "$FILES" story
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c '^/')" -eq 3 ]
  [[ "${lines[0]}" == *"/1.txt" ]]
  [[ "${lines[1]}" == *"/2.txt" ]]
  [[ "${lines[2]}" == *"/10.txt" ]]
}

@test "files.sh skips synopsis, dotfiles and non-txt files" {
  : > story/synopsis.txt
  : > story/.hidden.txt
  : > story/notes.md
  : > story/chapter.txt
  run sh "$FILES" story
  [ "$(printf '%s\n' "$output" | grep -c '^/')" -eq 1 ]
  [[ "${lines[0]}" == *"chapter.txt" ]]
}

@test "files.sh prints a single file alone, not its siblings" {
  : > story/a.txt; : > story/b.txt
  run sh "$FILES" story/a.txt
  [ "$(printf '%s\n' "$output" | grep -c '^/')" -eq 1 ]
  [[ "${lines[0]}" == *"/a.txt" ]]
  [[ "$output" == *"Layman Evaluation"* ]]
  [[ "$output" != *"Overall Summary"* ]]
  run sh "$FILES" story
  [[ "$output" == *"Overall Summary"* ]]
}

@test "files.sh prints a named file whatever its extension" {
  : > story/notes.md
  run sh "$FILES" story/notes.md
  [[ "${lines[0]}" == *"/notes.md" ]]
}

@test "files.sh prints absolute paths" {
  : > story/a.txt
  run sh "$FILES" story
  [[ "$output" == /* ]]
}

@test "files.sh fails on a missing path" {
  run sh "$FILES" story/nope.txt
  [ "$status" -ne 0 ]
}

@test "files.sh fails without exactly one argument" {
  run sh "$FILES"
  [ "$status" -eq 2 ]
}
