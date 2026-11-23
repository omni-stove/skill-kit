#!/usr/bin/env bats
# beats.sh, view.sh and build.sh — the sections of a layout, their beats and the build.

setup() {
  DIR="$BATS_TEST_DIRNAME"
  mkdir -p "$BATS_TEST_TMPDIR/repo/docs/design/maps" "$BATS_TEST_TMPDIR/repo/.agents/refs"
  cd "$BATS_TEST_TMPDIR/repo" || exit
  cat > .agents/refs/engine.sh <<'SH'
engine_name() { echo Unity; }
source_root() { echo Assets; }
headless_cmd() { echo unity -batchmode; }
runtime_log() { echo Editor.log; }
SH
}

layout() { printf '%s\n' "$1" > docs/design/maps/plain.json; }

@test "stops with the next step when the map has no layout file" {
  run sh "$DIR/beats.sh" plain
  [ "$status" -eq 1 ]
  [[ "$output" == *"lay the map out first"* ]]
}

@test "lists each section once in piece order with its beat's name, then the writing step" {
  layout '{"mode":"campaign","beats":[{"id":"c1","name":"river bed","notes":["checkpoint"]}],
    "pieces":[{"id":"s1-floor"},{"id":"c1-floor"},{"id":"s1-wall"},{"id":"goal"}]}'
  run sh "$DIR/beats.sh" plain
  [ "$status" -eq 0 ]
  [[ "$output" == *$'mode\tcampaign\nsection\ts1\t-\nsection\tc1\triver bed\nsection\tgoal\t-\n'* ]]
  [[ "$output" == *"into docs/design/maps/plain.json"* ]]
  [[ "$output" == *"view.sh plain"* ]]
}

@test "warns of a section without a beat, a beat without pieces and a beat without notes" {
  layout '{"beats":[{"id":"s1","name":"gap","notes":[]},{"id":"s9","name":"lost","notes":["x"]}],
    "pieces":[{"id":"s1-floor","kind":"floor","pos":[0,0,0],"size":[4,0.2,4]},
              {"id":"c1-floor","kind":"floor","pos":[0,0,8],"size":[4,0.2,4]}]}'
  run sh "$DIR/view.sh" plain
  [ "$status" -eq 0 ]
  [[ "$output" == *$'warn\tc1\tno beat'* ]]
  [[ "$output" == *$'warn\ts9\tno piece id starts with s9-'* ]]
  [[ "$output" == *$'warn\ts1\tno notes'* ]]
  [[ "$output" == *$'svg\tdocs/design/maps/plain.svg'* ]]
  [[ "$output" == *"build.sh plain"* ]]
  grep -q '>s1 gap</text>' docs/design/maps/plain.svg
}

@test "prints no warn line when every section has a beat with notes" {
  layout '{"beats":[{"id":"s1","name":"gap","notes":["teach attack"]}],
    "pieces":[{"id":"s1-floor","kind":"floor","pos":[0,0,0],"size":[4,0.2,4]}]}'
  run sh "$DIR/view.sh" plain
  [ "$status" -eq 0 ]
  [[ "$output" != *$'warn\t'* ]]
}

@test "build prints the engine facts and has the builder skip the notes fields" {
  layout '{"pieces":[{"id":"s1-floor"}]}'
  run sh "$DIR/build.sh" plain
  [ "$status" -eq 0 ]
  [[ "$output" == *$'source_root\tAssets'* ]]
  [[ "$output" == *"fails on beats, backdrop or a note"* ]]
}
