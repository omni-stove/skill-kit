#!/usr/bin/env bats
# save.sh — writes the judging report to its deterministic path and names the round that follows.

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
  path=$(printf '%s\n' "# 議論" "'反論' \$HOME \`x\`" | sh "$SAVE" novel.md discussion-1 | head -1)
  [ "$(cat "$path")" = "# 議論
'反論' \$HOME \`x\`" ]
  [[ "$path" == out/judge-full/novel-discussion-1-*.md ]]
}

@test "save.sh points from the first round to discussion-1 or the report" {
  run sh "$SAVE" novel.txt first-round <<< "tally"
  [[ "$output" == *'novel.txt" discussion-1'* ]]
  [[ "$output" == *'novel.txt" report'* ]]
  [[ "$output" != *"changed this round"* ]]
}

@test "save.sh continues the rounds only while a verdict changes" {
  run sh "$SAVE" novel.txt discussion-2 <<< "statements"
  [[ "$output" == *"changed this round"* ]]
  [[ "$output" == *'novel.txt" discussion-3'* ]]
  run sh "$SAVE" novel.txt report <<< "final"
  [ "${#lines[@]}" -eq 1 ]
}

@test "save.sh needs the manuscript and a label" {
  run sh "$SAVE" novel.txt
  [ "$status" -eq 2 ]
}
