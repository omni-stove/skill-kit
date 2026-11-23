#!/usr/bin/env bats
# view.sh — the layout drawn as an SVG, then the review step.

setup() {
  VIEW="$BATS_TEST_DIRNAME/view.sh"
  mkdir -p "$BATS_TEST_TMPDIR/repo/docs/design/maps"
  cd "$BATS_TEST_TMPDIR/repo" || exit
}

@test "fails with the next step when the layout file is missing" {
  run sh "$VIEW" arena
  [ "$status" -eq 1 ]
  [[ "$output" == *"write the layout file first"* ]]
  [[ "$output" != *"build.sh"* ]]
}

@test "prints the SVG path and has the user review it before the build" {
  printf '%s\n' '{"pieces":[{"id":"ground","kind":"floor","pos":[0,0,0],"size":[10,0.2,10]}]}' > docs/design/maps/arena.json
  run sh "$VIEW" arena
  [ "$status" -eq 0 ]
  [[ "$output" == *"svg	docs/design/maps/arena.svg"* ]]
  [[ "$output" == *"open docs/design/maps/arena.svg"* ]]
  [[ "$output" == *"view.sh arena"* ]]
  [[ "$output" == *"build.sh arena"* ]]
  [ -f docs/design/maps/arena.svg ]
}
