#!/usr/bin/env bats
# source.sh — the plot and its output file; draft.sh — the drafting step, held until the report is saved; gaps.sh — asking for what the marked passages lack, held until the draft is saved; finish.sh — the format fix and the feedback hand-off.

setup() {
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story/plot" "$work/sub"
  cd "$work" || exit
}

@test "source.sh drafts plot/<x>.md into the dir holding plot, named by the leading number" {
  : > story/plot/010-arrival.md
  run sh "$BATS_TEST_DIRNAME/source.sh" story/plot/010-arrival.md
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Output: story/010.txt" ]
  [[ "$output" == *'others.sh "story/plot/010-arrival.md"'* ]]
  [[ "$output" == *'draft.sh "story/plot/010-arrival.md" "story/010.txt" <the report file>'* ]]
  [[ "$output" != *"Overwrite"* ]]
}

@test "source.sh maps plot.md to index.txt and another .md to <stem>.txt" {
  : > sub/plot.md
  : > sub/03.md
  run sh "$BATS_TEST_DIRNAME/source.sh" sub/plot.md
  [ "${lines[0]}" = "Output: sub/index.txt" ]
  run sh "$BATS_TEST_DIRNAME/source.sh" sub/03.md
  [ "${lines[0]}" = "Output: sub/03.txt" ]
}

@test "source.sh asks before overwriting an existing output" {
  : > story/plot/010-arrival.md
  : > story/010.txt
  run sh "$BATS_TEST_DIRNAME/source.sh" story/plot/010-arrival.md
  [ "$status" -eq 0 ]
  [[ "$output" == *"Overwrite it with the draft?"* ]]
}

@test "source.sh refuses a story file and a missing plot" {
  : > story/010.txt
  run sh "$BATS_TEST_DIRNAME/source.sh" story/010.txt
  [ "$status" -eq 1 ]
  [[ "$output" == *"not a plot file"* ]]
  run sh "$BATS_TEST_DIRNAME/source.sh" story/plot/missing.md
  [ "$status" -eq 1 ]
}

@test "draft.sh prints the drafting step only once the report is saved" {
  : > story/plot/010-arrival.md
  run sh "$BATS_TEST_DIRNAME/draft.sh" story/plot/010-arrival.md story/010.txt report.txt
  [ "$status" -eq 1 ]
  [[ "$output" == *"wait for the Agent's report"* ]]
  printf 'レポート\n' > report.txt
  run sh "$BATS_TEST_DIRNAME/draft.sh" story/plot/010-arrival.md story/010.txt report.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *"Write every Scene"* ]]
  [[ "$output" == *'gaps.sh "story/plot/010-arrival.md" "story/010.txt" "report.txt"'* ]]
}

@test "gaps.sh prints the step to fill the marked passages only once the draft is saved" {
  : > story/plot/010-arrival.md
  run sh "$BATS_TEST_DIRNAME/gaps.sh" story/plot/010-arrival.md story/010.txt report.txt
  [ "$status" -eq 1 ]
  [[ "$output" == *"save the draft there"* ]]
  : > story/010.txt
  run sh "$BATS_TEST_DIRNAME/gaps.sh" story/plot/010-arrival.md story/010.txt report.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *"For each place marked in story/010.txt"* ]]
  [[ "$output" == *'finish.sh "story/plot/010-arrival.md" "story/010.txt"'* ]]
}

@test "finish.sh fixes the format, lists what is left, and hands back the feedback" {
  : > story/plot/010-arrival.md
  printf '彼は頷いた。\n「終わり。」\n　部屋は3つ。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/finish.sh" story/plot/010-arrival.md story/010.txt
  [ "$status" -eq 0 ]
  [ "$(head -2 story/010.txt)" = "$(printf '　彼は頷いた。\n「終わり」\n')" ]
  [[ "$output" == *"3:　部屋は3つ。"* ]]
  [[ "$output" == *"Leave story/plot/010-arrival.md as it is"*"story/010.txt drafted."* ]]
}

@test "finish.sh fails until the draft is saved" {
  : > story/plot/010-arrival.md
  run sh "$BATS_TEST_DIRNAME/finish.sh" story/plot/010-arrival.md story/010.txt
  [ "$status" -eq 1 ]
  [[ "$output" == *"save the draft there"* ]]
}
