#!/usr/bin/env bats
# encounter.sh, view.sh and build.sh — the encounter steps, the warnings and the SVG.

setup() {
  DIR="$BATS_TEST_DIRNAME"
  mkdir -p "$BATS_TEST_TMPDIR/repo/docs/design/maps" "$BATS_TEST_TMPDIR/repo/docs/design/encounters" "$BATS_TEST_TMPDIR/repo/.agents/refs"
  cd "$BATS_TEST_TMPDIR/repo" || exit
  cat > .agents/refs/engine.sh <<'SH'
engine_name() { echo Unity; }
source_root() { echo Assets; }
headless_cmd() { echo unity -batchmode; }
runtime_log() { echo Editor.log; }
control_mcp() { echo none; }
SH
  printf '%s\n' '{"mode":"campaign","pieces":[{"id":"g","kind":"floor","pos":[0,-0.2,0],"size":[20,0.2,20]},{"id":"r","kind":"ramp","pos":[8,0,0],"size":[2,1,4],"yaw":90}]}' > docs/design/maps/stage.json
}

@test "stops on a competitive map" {
  printf '%s\n' '{"mode":"competitive","pieces":[]}' > docs/design/maps/arena.json
  run sh "$DIR/encounter.sh" arena
  [ "$status" -eq 1 ]
  [[ "$output" == *"not a campaign map"* ]]
}

@test "prints the questions for a map with no encounter file, then the view step" {
  run sh "$DIR/encounter.sh" stage
  [ "$status" -eq 0 ]
  [[ "$output" == *"encounters	docs/design/encounters/stage.json"* ]]
  [[ "$output" == *"the enemy types"* ]]
  [[ "$output" == *"view.sh stage"* ]]
}

@test "warns of an unknown type, a missing trigger and an enemy off the floor, and draws the SVG" {
  printf '%s\n' '{"enemies":{"grunt":{"range":12}},"encounters":[
    {"id":"yard","intensity":2,"entry":[0,0,-8],"exit":[0,0,8],"waves":[{"start":"trigger","enemies":[
      {"type":"grunt","pos":[2,0,5],"hold":[8,0.5,0]},{"type":"ghost","pos":[30,0,0],"hold":[1,0,1]}]}]}]}' > docs/design/encounters/stage.json
  run sh "$DIR/view.sh" stage
  [ "$status" -eq 0 ]
  [[ "$output" == *"yard	no trigger"* ]]
  [[ "$output" == *"type ghost is not in enemies"* ]]
  [[ "$output" == *"ghost pos [30,0,0] is over no floor"* ]]
  [[ "$output" != *"grunt hold"* ]]
  [[ "$output" == *"svg	docs/design/encounters/stage.svg"* ]]
  grep -q 'yard ★2' docs/design/encounters/stage.svg
  grep -q 'url(#c)' docs/design/encounters/stage.svg
}

@test "fails with the fix on an enemy without a hold" {
  printf '%s\n' '{"encounters":[{"id":"yard","entry":[0,0,0],"exit":[0,0,1],"waves":[{"enemies":[{"type":"grunt","pos":[0,0,0]}]}]}]}' > docs/design/encounters/stage.json
  run sh "$DIR/view.sh" stage
  [ "$status" -eq 1 ]
  [[ "$output" == *"pos and hold [x, y, z]"* ]]
}

@test "prints the build and the play check handed to the user" {
  printf '%s\n' '{"encounters":[]}' > docs/design/encounters/stage.json
  run sh "$DIR/build.sh" stage
  [ "$status" -eq 0 ]
  [[ "$output" == *"Extend it by the loaded rules, build docs/design/maps/stage.json"* ]]
  [[ "$output" == *"Give the user the play check"* ]]
}
