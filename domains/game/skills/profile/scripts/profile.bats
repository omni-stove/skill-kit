#!/usr/bin/env bats
# profile.sh and report.sh — the budget and sample steps, and the per-section report.

setup() {
  DIR="$BATS_TEST_DIRNAME"
  mkdir -p "$BATS_TEST_TMPDIR/repo/docs/design/maps" "$BATS_TEST_TMPDIR/repo/.agents/refs"
  cd "$BATS_TEST_TMPDIR/repo" || exit
  cat > .agents/refs/engine.sh <<'SH'
engine_name() { echo Unity; }
source_root() { echo Assets; }
build_cmd() { echo unity -build; }
headless_cmd() { echo unity -batchmode; }
runtime_log() { echo Editor.log; }
control_mcp() { echo none; }
SH
  printf '%s\n' '{"mode":"campaign","pieces":[{"id":"s1-floor","kind":"floor","pos":[0,0,0],"size":[4,1,4]},{"id":"s1-wall","kind":"wall","pos":[0,0,2],"size":[4,3,1]},{"id":"s2-floor","kind":"floor","pos":[0,0,8],"size":[4,1,4]}]}' > docs/design/maps/stage.json
}

@test "asks for the budget when there is none, then the sample step" {
  run sh "$DIR/profile.sh" stage
  [ "$status" -eq 0 ]
  [[ "$output" == *"budget	docs/design/perf.json"* ]]
  [[ "$output" == *"which device"* ]]
  [[ "$output" == *"report.sh stage [log]"* ]]
  printf '%s\n' '{"platform":"deck","max":{"frame_ms":16.6}}' > docs/design/perf.json
  run sh "$DIR/profile.sh" stage
  [[ "$output" != *"which device"* ]]
}

@test "marks the sections over budget and fixes the one furthest over" {
  printf '%s\n' '{"platform":"deck","max":{"frame_ms":16.6,"draws":1000}}' > docs/design/perf.json
  printf '%s\n' 'x [Perf] stage s1 frame_ms=20 draws=900' '[Perf] other s2 frame_ms=99' '[Perf] stage s2 frame_ms=15 draws=3000' > Editor.log
  run sh "$DIR/report.sh" stage
  [ "$status" -eq 0 ]
  [[ "$output" == *"over	s1	frame_ms=20	draws=900"* ]]
  [[ "$output" == *"over	s2	frame_ms=15	draws=3000"* ]]
  [[ "$output" != *"worst"* ]]
  [[ "$output" == *"profiler in section s2"* ]]
}

@test "reports a section with no line, then says when all are within budget" {
  printf '%s\n' '{"platform":"deck","max":{"frame_ms":16.6}}' > docs/design/perf.json
  printf '%s\n' '[Perf] stage s1 frame_ms=10' > Editor.log
  run sh "$DIR/report.sh" stage
  [[ "$output" == *"missing	s2"* ]]
  [[ "$output" == *"log each missing section"* ]]
  printf '%s\n' '[Perf] stage s1 frame_ms=10' '[Perf] stage s2 frame_ms=12' > run.log
  run sh "$DIR/report.sh" stage run.log
  [ "$status" -eq 0 ]
  [[ "$output" == *"ok	s2	frame_ms=12"* ]]
  [[ "$output" == *"every section is within the budget"* ]]
}
