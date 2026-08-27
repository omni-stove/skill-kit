#!/usr/bin/env bats
# bundle.sh — one line-numbered bundle of the directory's files.

setup() {
  BUNDLE="$BATS_TEST_DIRNAME/bundle.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story"
  cd "$work"
}

@test "bundle.sh concatenates txt files in natural order, prefixing file and line" {
  printf 'a1\na2\n' > story/1.txt
  printf 'b1\n' > story/2.txt
  printf 'c1\n' > story/10.txt
  run sh "$BUNDLE" story
  [ "$status" -eq 0 ]
  path=$(printf '%s' "${lines[0]}" | cut -f1)
  [ "$(cat "$path")" = "$(printf '1.txt:1\ta1\n1.txt:2\ta2\n2.txt:1\tb1\n10.txt:1\tc1')" ]
}

@test "bundle.sh prints the bundle path and its line count" {
  printf 'a\nb\nc\n' > story/only.txt
  run sh "$BUNDLE" story
  [ "$(printf '%s' "$output" | cut -f2)" = "3 lines" ]
  [[ "$(printf '%s' "$output" | cut -f1)" == out/dupcheck-all/*_story.txt ]]
}

@test "bundle.sh accepts a file inside the directory" {
  printf 'a\n' > story/a.txt
  printf 'b\n' > story/b.txt
  run sh "$BUNDLE" story/b.txt
  path=$(printf '%s' "${lines[0]}" | cut -f1)
  [ "$(cat "$path")" = "$(printf 'a.txt:1\ta\nb.txt:1\tb')" ]
}

@test "bundle.sh skips synopsis, dotfiles and non-txt files" {
  printf 'x\n' > story/synopsis.txt
  printf 'x\n' > story/.hidden.txt
  printf 'x\n' > story/notes.md
  printf 'k\n' > story/only.txt
  run sh "$BUNDLE" story
  path=$(printf '%s' "${lines[0]}" | cut -f1)
  [ "$(cat "$path")" = "$(printf 'only.txt:1\tk')" ]
}

@test "bundle.sh replaces the previous run's bundle" {
  printf 'a\n' > story/a.txt
  run sh "$BUNDLE" story
  run sh "$BUNDLE" story
  path=$(printf '%s' "${lines[0]}" | cut -f1)
  [ "$(cat "$path")" = "$(printf 'a.txt:1\ta')" ]
}

@test "bundle.sh writes an empty bundle for an empty directory" {
  run sh "$BUNDLE" story
  [ "$status" -eq 0 ]
  path=$(printf '%s' "${lines[0]}" | cut -f1)
  [ -f "$path" ]
  [ ! -s "$path" ]
}

@test "bundle.sh fails on a missing path" {
  run sh "$BUNDLE" nope
  [ "$status" -ne 0 ]
}

@test "bundle.sh fails without exactly one argument" {
  run sh "$BUNDLE"
  [ "$status" -eq 2 ]
}
