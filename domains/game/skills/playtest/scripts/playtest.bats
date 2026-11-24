#!/usr/bin/env bats
# playtest.sh and heat.sh — the log and play steps, and the per-section counts and SVG.

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
  printf '%s\n' '{"mode":"campaign","beats":[{"id":"s1","name":"yard"},{"id":"s2","name":"hall"}],
    "pieces":[{"id":"s1-floor","kind":"floor","pos":[0,-0.2,0],"size":[10,0.2,10]},{"id":"s2-floor","kind":"floor","pos":[0,-0.2,10],"size":[10,0.2,10]}]}' > docs/design/maps/stage.json
}

@test "stops without a layout file" {
  run sh "$DIR/playtest.sh" none
  [ "$status" -eq 1 ]
  [[ "$output" == *"lay the map out first"* ]]
}

@test "prints the design files beside the layout, the log step and the play check" {
  printf '{}\n' > docs/design/encounters/stage.json
  run sh "$DIR/playtest.sh" stage
  [ "$status" -eq 0 ]
  [[ "$output" == *"design	docs/design/encounters/stage.json"* ]]
  [[ "$output" != *"spawns/stage.json"* ]]
  [[ "$output" == *"log the [Play] lines"* ]]
  [[ "$output" == *"heat.sh stage [log...] with the logs"* ]]
}

@test "fails when no log has a [Play] line" {
  printf 'nothing\n' > Editor.log
  run sh "$DIR/heat.sh" stage
  [ "$status" -eq 1 ]
  [[ "$output" == *"no [Play] lines"* ]]
}

@test "counts each section's events across logs, puts points off the map under -, and draws the SVG" {
  printf '%s\n' 'x [Play] death 1,0,1 from=4,0,4' '[Play] hit 2,0,2 from=4,0,4' '[Play] stuck 0,0,11' > a.log
  printf '%s\n' '[Play] death 1,0,12' '[Play] death 50,0,50' > b.log
  run sh "$DIR/heat.sh" stage a.log b.log
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "s1	yard	deaths=1	hits=1	stuck=0" ]]
  [[ "${lines[1]}" == "s2	hall	deaths=1	hits=0	stuck=1" ]]
  [[ "${lines[2]}" == "-		deaths=1	hits=0	stuck=0" ]]
  [[ "$output" == *"svg	docs/design/playtests/stage.svg"* ]]
  [[ "$output" == *"against its beat"* ]]
  grep -q '<title>death \[1,0,1\] from \[4,0,4\]</title>' docs/design/playtests/stage.svg
}
