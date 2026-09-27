#!/usr/bin/env bats
# synopsis.sh — the synopsis with its character count over the limit.

@test "synopsis.sh prints the character count without newlines over the limit, then the text" {
  printf 'あいう\nえお\n' > "$BATS_TEST_TMPDIR/synopsis.txt"
  run sh "$BATS_TEST_DIRNAME/synopsis.sh" "$BATS_TEST_TMPDIR/synopsis.txt" 1000
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "5/1000字" ]
  [ "${lines[1]}" = "あいう" ]
  [ "${lines[2]}" = "えお" ]
}
