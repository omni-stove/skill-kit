#!/usr/bin/env bats
# plots.sh — each plot paired with its output in draft/, and the step to draft them all.

setup() {
  PLOTS="$BATS_TEST_DIRNAME/plots.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story/plot"
  cd "$work" || exit
}

@test "plots.sh pairs each plot with draft/<leading number or stem>.txt in natural order" {
  : > story/plot/100-end.md
  : > story/plot/20-middle.md
  : > story/plot/prologue.md
  : > story/plot/.hidden.md
  run sh "$PLOTS"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "$(printf 'story/plot/20-middle.md\tdraft/20.txt')" ]
  [ "${lines[1]}" = "$(printf 'story/plot/100-end.md\tdraft/100.txt')" ]
  [ "${lines[2]}" = "$(printf 'story/plot/prologue.md\tdraft/prologue.txt')" ]
  [[ "$output" != *".hidden"* ]]
  [[ "$output" == *"Launch one Agent per plot"* ]]
  [[ "$output" == *"read every .md file in story/plot"* ]]
  [[ "$output" != *"Overwrite"* ]]
  [ -d draft ]
}

@test "plots.sh marks existing outputs and asks before overwriting them" {
  mkdir draft
  : > story/plot/010-a.md
  : > story/plot/020-b.md
  : > draft/020.txt
  run sh "$PLOTS"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Exists: draft/020.txt"* ]]
  [[ "$output" != *"Exists: draft/010.txt"* ]]
  [[ "$output" == *"Overwrite them with the new drafts?"* ]]
}

@test "plots.sh refuses two plots that draft into one file" {
  : > story/plot/010-a.md
  : > story/plot/010-b.md
  run sh "$PLOTS"
  [ "$status" -eq 1 ]
  [[ "$output" == *"more than one plot file drafts into draft/010.txt"* ]]
}

@test "plots.sh fails with no plot files or with an argument" {
  rm -r story/plot
  run sh "$PLOTS"
  [ "$status" -eq 1 ]
  [[ "$output" == *"no plot files in story/plot"* ]]
  run sh "$PLOTS" extra
  [ "$status" -eq 2 ]
}
