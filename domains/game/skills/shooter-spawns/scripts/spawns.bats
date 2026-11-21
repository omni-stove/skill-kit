#!/usr/bin/env bats
# spawns.sh and report.sh — the respawn steps and the per-point report from the log.

setup() {
  DIR="$BATS_TEST_DIRNAME"
  mkdir -p "$BATS_TEST_TMPDIR/repo/docs/design/maps" "$BATS_TEST_TMPDIR/repo/docs/design/spawns" "$BATS_TEST_TMPDIR/repo/.agents/refs"
  cd "$BATS_TEST_TMPDIR/repo" || exit
  cat > .agents/refs/engine.sh <<'SH'
engine_name() { echo Unity; }
source_root() { echo Assets; }
headless_cmd() { echo unity -batchmode; }
runtime_log() { echo Editor.log; }
control_mcp() { echo none; }
SH
  printf '%s\n' '{"mode":"competitive","spawns":[{"id":"a0","team":"a","pos":[0,0,0]},{"id":"a1","team":"a","use":"respawn","pos":[1,0,0]},{"id":"a2","team":"a","use":"respawn","pos":[2,0,0]}],"pieces":[]}' > docs/design/maps/arena.json
  printf '%s\n' '{"respawn":"each","delay":3,"protect":1,"min_enemy_time":4,"spawn_kill":3}' > docs/design/spawns/arena.json
}

@test "stops on a campaign map" {
  printf '%s\n' '{"mode":"campaign","pieces":[]}' > docs/design/maps/stage.json
  run sh "$DIR/spawns.sh" stage
  [ "$status" -eq 1 ]
  [[ "$output" == *"not a competitive map"* ]]
}

@test "prints the questions and the measure step for a map with no spawn file" {
  printf '%s\n' '{"mode":"competitive","pieces":[]}' > docs/design/maps/yard.json
  run sh "$DIR/spawns.sh" yard
  [ "$status" -eq 0 ]
  [[ "$output" == *"spawns	docs/design/spawns/yard.json"* ]]
  [[ "$output" == *"one by one or in waves"* ]]
  [[ "$output" == *"report.sh yard [log]"* ]]
}

@test "fails a point an enemy reaches too soon or sees, and reports a point with no line" {
  printf '%s\n' \
    'x [Spawn] a1 team=a enemy_time=2.5 from=b0 seen_by=-' \
    '[Spawn] a1 team=a enemy_time=6 from=b0 seen_by=b0' > Editor.log
  run sh "$DIR/report.sh" arena
  [ "$status" -eq 0 ]
  [[ "$output" == *"fail	a1	enemy_time=6	seen_by=b0"* ]]
  [[ "$output" == *"missing	a2"* ]]
  [[ "$output" != *"a0"* ]]
  [[ "$output" == *"move the point"* ]]
}

@test "asks for the selection when every point passes and nothing respawned yet" {
  printf '%s\n' '[Spawn] a1 team=a enemy_time=6 from=b0 seen_by=-' '[Spawn] a2 team=a enemy_time=5 from=b1 seen_by=-' > Editor.log
  run sh "$DIR/report.sh" arena
  [ "$status" -eq 0 ]
  [[ "$output" == *"ok	a1"* ]]
  [[ "$output" == *"respawn selection under Assets"* ]]
  [[ "$output" == *"Give the user the play check"* ]]
}

@test "counts respawns and spawn kills per point from a given log" {
  printf '%s\n' '[Spawn] a1 team=a enemy_time=6 from=b0 seen_by=-' '[Spawn] a2 team=a enemy_time=5 from=b1 seen_by=-' \
    '[Respawn] a1 died_after=1.2' '[Respawn] a1 died_after=40' '[Respawn] a2 died_after=12' > match.log
  run sh "$DIR/report.sh" arena match.log
  [ "$status" -eq 0 ]
  [[ "$output" == *"ok	a1	enemy_time=6	seen_by=-	respawns=2	spawn_kills=1"* ]]
  [[ "$output" == *"respawns=1	spawn_kills=0"* ]]
  [[ "$output" == *"Weigh each point"* ]]
}
