#!/usr/bin/env bats
# objectives.sh, view.sh and report.sh — the objective steps, the warnings and the per-objective report.

setup() {
  DIR="$BATS_TEST_DIRNAME"
  mkdir -p "$BATS_TEST_TMPDIR/repo/docs/design/maps" "$BATS_TEST_TMPDIR/repo/docs/design/objectives" "$BATS_TEST_TMPDIR/repo/.agents/refs"
  cd "$BATS_TEST_TMPDIR/repo" || exit
  cat > .agents/refs/engine.sh <<'SH'
engine_name() { echo Unity; }
source_root() { echo Assets; }
headless_cmd() { echo unity -batchmode; }
runtime_log() { echo Editor.log; }
control_mcp() { echo none; }
SH
  printf '%s\n' '{"mode":"competitive","spawns":[{"team":"atk","pos":[0,0,-9]},{"team":"def","pos":[0,0,9]}],
    "objectives":[{"id":"a","kind":"site","team":"def","pos":[-5,0,5],"size":[4,1,4]},{"id":"mid","kind":"point","pos":[0,0,0],"size":[4,1,4]}],
    "pieces":[{"id":"g","kind":"floor","pos":[0,-0.2,0],"size":[20,0.2,20]}]}' > docs/design/maps/arena.json
  printf '%s\n' '{"game":"plant at a site","take":5,"lead":4,"even":2}' > docs/design/objectives/arena.json
}

@test "stops on a campaign map" {
  printf '%s\n' '{"mode":"campaign","pieces":[]}' > docs/design/maps/stage.json
  run sh "$DIR/objectives.sh" stage
  [ "$status" -eq 1 ]
  [[ "$output" == *"not a competitive map"* ]]
}

@test "prints the questions for a map with no objective file, then the view step" {
  printf '%s\n' '{"mode":"competitive","pieces":[]}' > docs/design/maps/yard.json
  run sh "$DIR/objectives.sh" yard
  [ "$status" -eq 0 ]
  [[ "$output" == *"objectives	docs/design/objectives/yard.json"* ]]
  [[ "$output" == *"which team defends which objective"* ]]
  [[ "$output" == *"view.sh yard"* ]]
}

@test "warns of a missing id, a repeated id and a team no spawn starts, and draws the SVG" {
  printf '%s\n' '{"mode":"competitive","spawns":[{"team":"atk","pos":[0,0,0]}],
    "objectives":[{"kind":"site","pos":[1,0,1],"size":[2,1,2]},{"id":"b","team":"ghost","pos":[3,0,3],"size":[2,1,2]},{"id":"b","pos":[5,0,5],"size":[2,1,2]}],
    "pieces":[{"id":"g","kind":"floor","pos":[0,-0.2,0],"size":[20,0.2,20]}]}' > docs/design/maps/yard.json
  run sh "$DIR/view.sh" yard
  [ "$status" -eq 0 ]
  [[ "$output" == *"has no id"* ]]
  [[ "$output" == *"b	no start spawn of team ghost"* ]]
  [[ "$output" == *"b	id used 2 times"* ]]
  [[ "$output" == *"svg	docs/design/maps/yard.svg"* ]]
  [[ "$output" == *"report.sh yard [log]"* ]]
  [ -f docs/design/maps/yard.svg ]
}

@test "fails a defended objective reached too late and a contested one reached unevenly, and reports a missing one" {
  printf '%s\n' 'x [Objective] a atk=10 def=8 rotate=6' '[Objective] mid atk=9 def=12 rotate=-' > Editor.log
  run sh "$DIR/report.sh" arena
  [ "$status" -eq 0 ]
  [[ "$output" == *"fail	a	atk=10	def=8	gap=2	rotate=6	takes=-"* ]]
  [[ "$output" == *"fail	mid	atk=9	def=12	gap=3"* ]]
  [[ "$output" == *"move the objective"* ]]
  printf '%s\n' '[Objective] a atk=14 def=8 rotate=6' > Editor.log
  run sh "$DIR/report.sh" arena
  [[ "$output" == *"ok	a"* ]]
  [[ "$output" == *"missing	mid"* ]]
  printf '%s\n' '[Objective] a atk=- def=8 rotate=6' '[Objective] mid atk=9 def=10 rotate=-' > Editor.log
  run sh "$DIR/report.sh" arena
  [[ "$output" == *"fail	a	atk=-	def=8"* ]]
}

@test "asks for the take log and the play check when every objective passes and none was taken yet" {
  printf '%s\n' '[Objective] a atk=14 def=8 rotate=6' '[Objective] mid atk=9 def=10 rotate=-' > Editor.log
  run sh "$DIR/report.sh" arena
  [ "$status" -eq 0 ]
  [[ "$output" == *"ok	mid	atk=9	def=10	gap=1"* ]]
  [[ "$output" == *"took an objective under Assets"* ]]
  [[ "$output" == *"Give the user the play check"* ]]
}

@test "counts takes per team from a given log, then the weigh step" {
  printf '%s\n' '[Objective] a atk=14 def=8 rotate=6' '[Objective] mid atk=9 def=10 rotate=-' \
    '[Take] a team=atk at=50' '[Take] a team=atk at=61' '[Take] mid team=def at=20' > match.log
  run sh "$DIR/report.sh" arena match.log
  [ "$status" -eq 0 ]
  [[ "$output" == *"ok	a	atk=14	def=8	gap=6	rotate=6	takes=atk:2,def:0"* ]]
  [[ "$output" == *"takes=atk:0,def:1"* ]]
  [[ "$output" == *"Weigh each objective"* ]]
}
