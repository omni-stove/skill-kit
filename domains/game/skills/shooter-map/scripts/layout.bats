#!/usr/bin/env bats
# layout.sh and build.sh — the layout and build steps printed for the map's mode.

setup() {
  DIR="$BATS_TEST_DIRNAME"
  mkdir -p "$BATS_TEST_TMPDIR/repo/docs/design/maps" "$BATS_TEST_TMPDIR/repo/.agents/refs"
  cd "$BATS_TEST_TMPDIR/repo" || exit
  cat > .agents/refs/engine.sh <<'SH'
engine_name() { echo Unity; }
source_root() { echo Assets; }
headless_cmd() { echo unity -batchmode; }
runtime_log() { echo Editor.log; }
control_mcp() { echo none; }
SH
}

@test "asks to settle the mode when neither the argument nor the layout file gives it" {
  run sh "$DIR/layout.sh" stage-1
  [ "$status" -eq 0 ]
  [[ "$output" == *"campaign or for competitive play"* ]]
  [[ "$output" == *"layout.sh stage-1 <campaign|competitive>"* ]]
  [[ "$output" != *"engine	"* ]]
}

@test "prints the campaign layout and questions for a new campaign map" {
  run sh "$DIR/layout.sh" stage-1 campaign
  [ "$status" -eq 0 ]
  [[ "$output" == *"mode	campaign"* ]]
  [[ "$output" == *"chain of combat spaces"* ]]
  [[ "$output" == *"number of fights and play time"* ]]
  [[ "$output" != *"mirror the layout"* ]]
}

@test "prints the competitive layout and questions for a new competitive map" {
  run sh "$DIR/layout.sh" arena competitive
  [ "$status" -eq 0 ]
  [[ "$output" == *"mirror the layout"* ]]
  [[ "$output" == *"by its team sizes"* ]]
  [[ "$output" != *"combat spaces"* ]]
}

@test "takes the mode from an existing layout file and prints the edit step" {
  printf '{"mode":"campaign","pieces":[]}\n' > docs/design/maps/stage-1.json
  run sh "$DIR/layout.sh" stage-1
  [ "$status" -eq 0 ]
  [[ "$output" == *"chain of combat spaces"* ]]
  [[ "$output" == *"set its mode to campaign"* ]]
}

@test "rejects an unknown mode" {
  run sh "$DIR/layout.sh" stage-1 pvp
  [ "$status" -eq 1 ]
  [[ "$output" == *"campaign or competitive"* ]]
}

@test "build adds the newcomer walk only for a campaign layout" {
  printf '{"mode":"campaign","pieces":[]}\n' > docs/design/maps/stage-1.json
  printf '{"mode":"competitive","pieces":[]}\n' > docs/design/maps/arena.json
  run sh "$DIR/build.sh" stage-1
  [ "$status" -eq 0 ]
  [[ "$output" == *"has not seen the layout"* ]]
  run sh "$DIR/build.sh" arena
  [ "$status" -eq 0 ]
  [[ "$output" != *"has not seen the layout"* ]]
}

@test "build stops on a layout file without a mode" {
  printf '{"pieces":[]}\n' > docs/design/maps/old.json
  run sh "$DIR/build.sh" old
  [ "$status" -eq 1 ]
  [[ "$output" == *"run layout.sh old"* ]]
}
