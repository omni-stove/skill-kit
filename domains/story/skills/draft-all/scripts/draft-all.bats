#!/usr/bin/env bats
# plots.sh — the plots to draft and the step to check them; write.sh — the drafting step, held until every report is saved; report.sh — draft/report.md built from the notes.

setup() {
  PLOTS="$BATS_TEST_DIRNAME/plots.sh"
  WRITE="$BATS_TEST_DIRNAME/write.sh"
  REPORT="$BATS_TEST_DIRNAME/report.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story/plot"
  cd "$work" || exit
}

@test "plots.sh lists each plot with its report file in natural order" {
  : > story/plot/100-end.md
  : > story/plot/20-middle.md
  : > story/plot/prologue.md
  : > story/plot/.hidden.md
  run sh "$PLOTS"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "$(printf 'story/plot/20-middle.md\tdraft/.report/20.check.md')" ]
  [ "${lines[1]}" = "$(printf 'story/plot/100-end.md\tdraft/.report/100.check.md')" ]
  [ "${lines[2]}" = "$(printf 'story/plot/prologue.md\tdraft/.report/prologue.check.md')" ]
  [[ "$output" != *".hidden"* ]]
  [[ "$output" == *"definition of the report on"* ]]
  [[ "$output" == *"others.sh --earlier <its plot file>"* ]]
  [[ "$output" == *"write.sh"* ]]
  [[ "$output" != *"Overwrite"* ]]
  [ "$(sed -n 1p draft/.report/plots.tsv)" = "$(printf 'story/plot/20-middle.md\tdraft/20.txt\tdraft/.report/20.check.md\tdraft/.report/20.notes.md')" ]
}

@test "plots.sh marks existing outputs and stops to ask before overwriting them" {
  mkdir draft
  : > story/plot/010-a.md
  : > story/plot/020-b.md
  : > draft/020.txt
  run sh "$PLOTS"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Exists: draft/020.txt"* ]]
  [[ "$output" != *"Exists: draft/010.txt"* ]]
  [[ "$output" == *"Overwrite them with the new drafts?"* ]]
  [[ "$output" == *"plots.sh --overwrite on yes"*"plots.sh --keep on no"* ]]
  [ ! -e draft/.report ]
}

@test "plots.sh --overwrite lists every plot and --keep only those with no output" {
  mkdir draft
  : > story/plot/010-a.md
  : > story/plot/020-b.md
  : > draft/020.txt
  run sh "$PLOTS" --overwrite
  [ "$status" -eq 0 ]
  [ "$(wc -l < draft/.report/plots.tsv | tr -d ' ')" = 2 ]
  run sh "$PLOTS" --keep
  [ "$status" -eq 0 ]
  [ "$(wc -l < draft/.report/plots.tsv | tr -d ' ')" = 1 ]
  [[ "$(cat draft/.report/plots.tsv)" == story/plot/010-a.md* ]]
}

@test "plots.sh --keep fails when every plot has an output" {
  mkdir draft
  : > story/plot/010-a.md
  : > draft/010.txt
  run sh "$PLOTS" --keep
  [ "$status" -eq 1 ]
  [[ "$output" == *"none is left to draft"* ]]
  [ ! -e draft/.report ]
}

@test "plots.sh clears the working files of an earlier run" {
  mkdir -p draft/.report
  : > draft/.report/stale.notes.md
  : > story/plot/010-a.md
  run sh "$PLOTS"
  [ "$status" -eq 0 ]
  [ ! -e draft/.report/stale.notes.md ]
}

@test "plots.sh refuses two plots that draft into one file" {
  : > story/plot/010-a.md
  : > story/plot/010-b.md
  run sh "$PLOTS"
  [ "$status" -eq 1 ]
  [[ "$output" == *"more than one plot file drafts into draft/010.txt"* ]]
}

@test "plots.sh fails with no plot files or with an unknown argument" {
  rm -r story/plot
  run sh "$PLOTS"
  [ "$status" -eq 1 ]
  [[ "$output" == *"no plot files in story/plot"* ]]
  run sh "$PLOTS" extra
  [ "$status" -eq 2 ]
}

@test "write.sh prints the drafting step only once every report is saved" {
  : > story/plot/010-a.md
  : > story/plot/020-b.md
  sh "$PLOTS" > /dev/null
  printf 'レポート\n' > draft/.report/010.check.md
  run sh "$WRITE"
  [ "$status" -eq 1 ]
  [[ "$output" == *"story/plot/020-b.md"* ]]
  [[ "$output" != *"story/plot/010-a.md"* ]]
  printf 'レポート\n' > draft/.report/020.check.md
  run sh "$WRITE"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "$(printf 'story/plot/010-a.md\tdraft/010.txt\tdraft/.report/010.check.md\tdraft/.report/010.notes.md')" ]
  [[ "$output" == *"Launch one Agent per plot"* ]]
  [[ "$output" == *"read its report file and every .md file in story/plot"* ]]
  [[ "$output" == *"plays out each event of the plot body"* ]]
  [[ "$output" == *"brings the whole text to at least the length under its plot's ## Length"* ]]
  [[ "$output" == *"notes and marks places by the loaded rules without asking"* ]]
  [[ "$output" == *".agents/refs/length.sh <its plot file>"* ]]
  [[ "$output" == *"report.sh"* ]]
}

@test "write.sh and report.sh fail before plots.sh has run" {
  run sh "$WRITE"
  [ "$status" -eq 1 ]
  [[ "$output" == *"run plots.sh first"* ]]
  run sh "$REPORT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"run plots.sh first"* ]]
}

@test "report.sh writes draft/report.md with what was written, undrafted and short, then the notes" {
  : > story/plot/010-a.md
  printf '本文\n\n## Length\n100字\n' > story/plot/020-b.md
  : > story/plot/030-c.md
  sh "$PLOTS" > /dev/null
  printf '本文。\n' > draft/010.txt
  printf 'Scene 1: 動機が足りない\n' > draft/.report/010.notes.md
  printf '彼は頷いた。\n' > draft/020.txt
  printf 'プロットは足りていた\n' > draft/.report/020.notes.md
  run sh "$REPORT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Report: draft/report.md" ]
  [[ "$output" == *"Written:"*"draft/010.txt"*"draft/020.txt"*"Undrafted:"*"story/plot/030-c.md"*"Short:"*"draft/020.txt 6/100字"* ]]
  [[ "$output" == *"Reply with the lines above"* ]]
  [[ "$(cat draft/report.md)" == "# Draft report"*"Short:"*"## draft/010.txt (story/plot/010-a.md)"*"Scene 1: 動機が足りない"*"## draft/020.txt (story/plot/020-b.md)"*"プロットは足りていた"* ]]
  [[ "$(cat draft/report.md)" != *"## draft/030.txt"* ]]
  [ ! -e draft/.report ]
}

@test "report.sh counts an earlier output with no notes as undrafted" {
  mkdir draft
  : > story/plot/010-a.md
  printf '前の下書き\n' > draft/010.txt
  sh "$PLOTS" --overwrite > /dev/null
  run sh "$REPORT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Undrafted:"*"story/plot/010-a.md"* ]]
  [[ "$output" != *"Written:"* ]]
}
