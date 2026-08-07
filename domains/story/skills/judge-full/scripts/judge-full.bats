#!/usr/bin/env bats
# save.sh — writes the judging report to its deterministic path.

setup() {
  SAVE="$BATS_TEST_DIRNAME/save.sh"
  cd "$BATS_TEST_TMPDIR"
}

@test "save.sh names the report after the manuscript, extension stripped" {
  run sh "$SAVE" story/novel.txt "# report"
  [ "$status" -eq 0 ]
  [[ "$output" == out/novel-judge-full-*.md ]]
}

@test "save.sh writes the report content to the printed path" {
  path=$(sh "$SAVE" novel.md "# 最終審査結果
大賞")
  [ "$(cat "$path")" = "# 最終審査結果
大賞" ]
}
