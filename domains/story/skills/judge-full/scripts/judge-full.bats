#!/usr/bin/env bats
# save.sh — writes the judging report to its deterministic path.

setup() {
  SAVE="$BATS_TEST_DIRNAME/save.sh"
  cd "$BATS_TEST_TMPDIR"
}

@test "save.sh names the report after the manuscript and label, extension stripped" {
  run sh "$SAVE" story/novel.txt report <<< "# report"
  [ "$status" -eq 0 ]
  [[ "$output" == out/judge-full/novel-report-*.md ]]
}

@test "save.sh writes the report content to the printed path" {
  path=$(printf '%s\n' "# 議論" "'反論' \$HOME \`x\`" | sh "$SAVE" novel.md discussion)
  [ "$(cat "$path")" = "# 議論
'反論' \$HOME \`x\`" ]
  [[ "$path" == out/judge-full/novel-discussion-*.md ]]
}
