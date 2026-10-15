#!/usr/bin/env bats
# record.sh — control_mcp set in a real engine.sh, a symlinked default copied first.

setup() {
  RECORD="$BATS_TEST_DIRNAME/record.sh"
  repo="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$repo/.agents/refs" "$BATS_TEST_TMPDIR/kit"
  printf 'engine_name() { echo "Unity"; }\ncontrol_mcp()        { echo ""; }   # e.g. "mcp__unity__"\n' > "$BATS_TEST_TMPDIR/kit/engine.sh"
  cd "$repo"
}

@test "fails with the sync hint when engine.sh is missing" {
  run sh "$RECORD" mcp__unity__
  [ "$status" -eq 1 ]
  [[ "$output" == *"skill-kit game sync"* ]]
}

@test "turns the symlinked default into a real file and records the prefix" {
  ln -s "$BATS_TEST_TMPDIR/kit/engine.sh" .agents/refs/engine.sh
  run sh "$RECORD" mcp__unity__
  [ "$status" -eq 0 ]
  [ ! -L .agents/refs/engine.sh ]
  [[ "$output" == *"copied	.agents/refs/engine.sh"* ]]
  [[ "$output" == *"control_mcp	mcp__unity__"* ]]
  [[ "$output" == *"mcp__unity__*"* ]]
  [[ "$output" == *'warning	.mcp.json has no server named "unity"'* ]]
  echo '{"mcpServers":{"unity":{"command":"x"}}}' > .mcp.json
  PATH=/usr/bin:/bin run sh "$RECORD" mcp__unity__
  [[ "$output" == *"server	unity — configured"* ]]
  [[ "$output" != *"warning"* ]]
  [ "$(sh -c '. .agents/refs/engine.sh; control_mcp')" = "mcp__unity__" ]
  [ "$(sh -c '. .agents/refs/engine.sh; engine_name')" = "Unity" ]
  [ "$(sh -c '. "$0"; control_mcp' "$BATS_TEST_TMPDIR/kit/engine.sh")" = "" ]
}

@test "changes only control_mcp in a real file, and unsets it with an empty prefix" {
  cp "$BATS_TEST_TMPDIR/kit/engine.sh" .agents/refs/engine.sh
  sh "$RECORD" mcp__godot__ >/dev/null
  [ "$(sh -c '. .agents/refs/engine.sh; control_mcp')" = "mcp__godot__" ]
  run sh "$RECORD" ""
  [ "$status" -eq 0 ]
  [ "$(sh -c '. .agents/refs/engine.sh; control_mcp')" = "" ]
  [[ "$output" == *"log-scraping"* ]]
  [ "$(grep -c '' .agents/refs/engine.sh)" -eq 2 ]
}

@test "fails when the file has no control_mcp function" {
  echo 'engine_name() { echo "X"; }' > .agents/refs/engine.sh
  run sh "$RECORD" mcp__x__
  [ "$status" -eq 1 ]
}
