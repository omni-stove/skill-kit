#!/usr/bin/env bats
# source.sh — the plot, its output file and check file; draft.sh — the drafting step, held until the report is saved; gaps.sh — asking for what the marked passages lack, held until the draft is saved; finish.sh — the format fix and the step to save the notes; report.sh — the report file built from the notes.

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
  [[ "$output" == *'others.sh --earlier "story/plot/010-arrival.md"'* ]]
  [[ "$output" == *'story/outline.md, story/synopsis.txt, draft/ and'* ]]
  [[ "$output" == *'save to story/report/.010.check.md'* ]]
  [[ "$output" == *'draft.sh "story/plot/010-arrival.md" "story/010.txt" "story/report/.010.check.md"'* ]]
  [[ "$output" != *"Overwrite"* ]]
  [ -d story/report ]
}

@test "source.sh clears the working files of an earlier run" {
  : > story/plot/010-arrival.md
  mkdir story/report
  printf '古い\n' > story/report/.010.check.md
  printf '古い\n' > story/report/.010.notes.md
  printf '残す\n' > story/report/010.md
  run sh "$BATS_TEST_DIRNAME/source.sh" story/plot/010-arrival.md
  [ "$status" -eq 0 ]
  [ ! -e story/report/.010.check.md ]
  [ ! -e story/report/.010.notes.md ]
  [ -f story/report/010.md ]
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
  [[ "$output" == *"wait for the Agent to save it there"* ]]
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

@test "gaps.sh says a draft is short of its length before the step to fill it" {
  printf '本文\n\n## Length\n100字\n' > story/plot/010-arrival.md
  printf '彼は頷いた。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/gaps.sh" story/plot/010-arrival.md story/010.txt report.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *"Mark the passages that need more"*"6/100字"*"For each place marked"* ]]
}

@test "finish.sh fixes the format, lists what is left, and asks for the notes" {
  : > story/plot/010-arrival.md
  printf '彼は頷いた。\n「終わり。」\n　部屋は3つ。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/finish.sh" story/plot/010-arrival.md story/010.txt
  [ "$status" -eq 0 ]
  [ "$(head -2 story/010.txt)" = "$(printf '　彼は頷いた。\n「終わり」\n')" ]
  [[ "$output" == *"3:　部屋は3つ。"* ]]
  [[ "$output" == *"Leave story/plot/010-arrival.md as it is, save the notes to story/report/.010.notes.md"* ]]
  [[ "$output" == *'report.sh "story/plot/010-arrival.md" "story/010.txt"'* ]]
}

@test "finish.sh fails until the draft is saved" {
  : > story/plot/010-arrival.md
  run sh "$BATS_TEST_DIRNAME/finish.sh" story/plot/010-arrival.md story/010.txt
  [ "$status" -eq 1 ]
  [[ "$output" == *"save the draft there"* ]]
}

@test "report.sh fails until the notes are saved" {
  : > story/plot/010-arrival.md
  : > story/010.txt
  mkdir story/report
  run sh "$BATS_TEST_DIRNAME/report.sh" story/plot/010-arrival.md story/010.txt
  [ "$status" -eq 1 ]
  [[ "$output" == *"save them there"* ]]
}

@test "report.sh builds the report from the notes and removes the working files" {
  : > story/plot/010-arrival.md
  : > story/010.txt
  mkdir story/report
  printf 'レポート\n' > story/report/.010.check.md
  printf 'Scene 1: 動機が足りない\n' > story/report/.010.notes.md
  run sh "$BATS_TEST_DIRNAME/report.sh" story/plot/010-arrival.md story/010.txt
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Report: story/report/010.md" ]
  [ "${lines[1]}" = "Reply with the lines above as they stand." ]
  [ "$(cat story/report/010.md)" = "$(printf '# Draft report: story/010.txt (story/plot/010-arrival.md)\n\nScene 1: 動機が足りない')" ]
  [ ! -e story/report/.010.check.md ]
  [ ! -e story/report/.010.notes.md ]
}

@test "report.sh says when the draft is short of its length" {
  printf '本文\n\n## Length\n100字\n' > story/plot/010-arrival.md
  printf '彼は頷いた。\n' > story/010.txt
  mkdir story/report
  printf 'プロットは足りていた\n' > story/report/.010.notes.md
  run sh "$BATS_TEST_DIRNAME/report.sh" story/plot/010-arrival.md story/010.txt
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Short: 6/100字" ]
  [[ "$(cat story/report/010.md)" == *"Short: 6/100字"*"プロットは足りていた"* ]]
}

@test "report_file strips ./ for an output in the current directory" {
  . "$BATS_TEST_DIRNAME/report-file.sh"
  [ "$(report_file 03.txt)" = "report/03.md" ]
  [ "$(report_file 03.txt check)" = "report/.03.check.md" ]
  [ "$(report_file sub/index.txt notes)" = "sub/report/.index.notes.md" ]
}
