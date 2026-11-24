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

@test "draws a melee enemy as an arrow to where it meets the player and warns of a crowd past the surround" {
  printf '%s\n' '{"enemies":{"spear":{"attack":"melee","range":2},"archer":{"attack":"ranged","range":20}},
    "surround":{"enemies":2,"radius":3},
    "encounters":[{"id":"yard","entry":[0,0,-8],"exit":[0,0,8],"trigger":{"pos":[0,0,-6],"size":[4,2,2]},"waves":[{"start":"trigger","enemies":[
      {"type":"spear","pos":[-6,0,6],"hold":[0,0,0]},{"type":"spear","pos":[6,0,6],"hold":[1,0,1]},
      {"type":"spear","pos":[0,0,9],"hold":[-1,0,1]},{"type":"archer","pos":[5,0,9],"hold":[1,0,0]}]}]}]}' > docs/design/encounters/stage.json
  run sh "$DIR/view.sh" stage
  [ "$status" -eq 0 ]
  [[ "$output" == *$'yard wave 1\t3 melee enemies within 3 m of '*', over surround 2'* ]]
  [ "$(grep -o 'spear meets the player' docs/design/encounters/stage.svg | wc -l)" -eq 3 ]
  [ "$(grep -o 'marker-end="url(#m0)"' docs/design/encounters/stage.svg | wc -l)" -eq 3 ]
  grep -q 'archer hold' docs/design/encounters/stage.svg
  ! command -v xmllint >/dev/null || xmllint --noout docs/design/encounters/stage.svg
}

@test "warns when melee enemies have no surround" {
  printf '%s\n' '{"enemies":{"spear":{"attack":"melee"}},"encounters":[{"id":"yard","entry":[0,0,-8],"exit":[0,0,8],"trigger":{"pos":[0,0,-6],"size":[4,2,2]},
    "waves":[{"enemies":[{"type":"spear","pos":[0,0,5],"hold":[0,0,0]}]}]}]}' > docs/design/encounters/stage.json
  run sh "$DIR/view.sh" stage
  [ "$status" -eq 0 ]
  [[ "$output" == *"no surround for the melee enemies"* ]]
}

@test "warns of an encounter without intensity and a last encounter that is not the hardest, and charts the pacing" {
  printf '%s\n' '{"enemies":{"grunt":{"attack":"ranged"},"dog":{"attack":"melee"}},"surround":{"enemies":3,"radius":4},"encounters":[
    {"id":"yard","intensity":4,"entry":[0,0,-8],"exit":[0,0,0],"trigger":{"pos":[0,0,-6],"size":[4,2,1]},"waves":[{"start":"trigger","enemies":[
      {"type":"grunt","pos":[2,0,5],"hold":[2,0,4]},{"type":"dog","pos":[1,0,5],"hold":[1,0,1]}]}]},
    {"id":"gap","entry":[0,0,0],"exit":[0,0,4],"trigger":{"pos":[0,0,1],"size":[4,2,1]},"waves":[]},
    {"id":"hall","intensity":2,"entry":[0,0,4],"exit":[0,0,8],"trigger":{"pos":[0,0,5],"size":[4,2,1]},"waves":[{"start":"trigger","enemies":[
      {"type":"grunt","pos":[3,0,7],"hold":[3,0,6]}]}]}]}' > docs/design/encounters/stage.json
  run sh "$DIR/view.sh" stage
  [ "$status" -eq 0 ]
  [[ "$output" == *"gap	no intensity"* ]]
  [[ "$output" == *"hall	the last encounter is not the hardest (intensity 2 of 4)"* ]]
  grep -q '<title>yard 1 melee</title>' docs/design/encounters/stage.svg
  grep -q '★4 2 enemies' docs/design/encounters/stage.svg
}
