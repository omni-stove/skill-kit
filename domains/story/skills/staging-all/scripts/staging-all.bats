#!/usr/bin/env bats
# fix.sh — the fix rules; save.sh — the record and the fix step.

setup() {
  DIR="$BATS_TEST_DIRNAME"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story"
  cd "$work"
  : > story/1.txt
}

@test "fix.sh prints the fix rules and the target file" {
  run sh "$DIR/fix.sh" story/1.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *"Treat as a defect only"* ]]
  [[ "$output" == *"story/1.txt"* ]]
}

@test "fix.sh fails on a missing file" {
  run sh "$DIR/fix.sh" story/none.txt
  [ "$status" -eq 1 ]
}

@test "save.sh writes the record and points at fix.sh" {
  run sh "$DIR/save.sh" story/1.txt <<< "report"
  [ "$status" -eq 0 ]
  [ "$(cat "${lines[0]}")" = "report" ]
  [[ "$output" == *"/fix.sh"* ]]
  [[ "$output" != *"{fix}"* ]]
}
