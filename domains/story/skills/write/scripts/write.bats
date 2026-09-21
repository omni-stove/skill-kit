#!/usr/bin/env bats
# source.sh — deterministic resolution of the source and its output file; scene-check.sh — the checks before each hand-off.

setup() {
  SOURCE="$BATS_TEST_DIRNAME/source.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story/plot" "$work/sub/plot"
  cd "$work"
}

@test "source.sh writes plot/<x>.md to the dir holding plot, named by the leading number" {
  : > story/plot/010-co-arrival.md
  run sh "$SOURCE" story/plot/010-co-arrival.md
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Source: story/plot/010-co-arrival.md" ]
  [ "${lines[1]}" = "Output: story/010.txt" ]
}

@test "source.sh names the output after the whole stem when there is no leading number" {
  : > story/plot/arrival.md
  run sh "$SOURCE" story/plot/arrival.md
  [ "${lines[1]}" = "Output: story/arrival.txt" ]
}

@test "source.sh keeps the plot dir's parent for a nested plot" {
  : > sub/plot/020.md
  run sh "$SOURCE" sub/plot/020.md
  [ "${lines[1]}" = "Output: sub/020.txt" ]
}

@test "source.sh writes plot.md to index.txt beside it" {
  : > sub/plot.md
  run sh "$SOURCE" sub/plot.md
  [ "${lines[0]}" = "Source: sub/plot.md" ]
  [ "${lines[1]}" = "Output: sub/index.txt" ]
}

@test "source.sh writes another .md to <stem>.txt beside it" {
  : > story/03.md
  run sh "$SOURCE" story/03.md
  [ "${lines[1]}" = "Output: story/03.txt" ]
}

@test "source.sh revises a .txt in place" {
  : > story/010.txt
  run sh "$SOURCE" story/010.txt
  [ "${lines[0]}" = "Output: story/010.txt" ]
  [[ "$output" == *"revise it"* ]]
}

@test "source.sh says to start fresh when the output is missing" {
  : > story/plot/arrival.md
  run sh "$SOURCE" story/plot/arrival.md
  [[ "$output" == *"does not exist yet"* ]]
}

@test "source.sh says to read and ask when the output exists" {
  : > story/plot/010-co-arrival.md
  : > story/010.txt
  run sh "$SOURCE" story/plot/010-co-arrival.md
  [[ "$output" == *"Read it, ask"* ]]
}

@test "source.sh fails on a missing source" {
  run sh "$SOURCE" story/plot/missing.md
  [ "$status" -eq 1 ]
}

@test "scene-check.sh prints the five whole-file checks" {
  printf '　彼は頷いた。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/scene-check.sh" story/010.txt
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c '^- ')" -eq 5 ]
}

@test "scene-check.sh lists look-or-voice sentence endings" {
  printf '　彼は頷いた。覚悟を決めた目だった。\n\n◇◇◇\n\n　静かな声だった。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/scene-check.sh" story/010.txt
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c '^- ')" -eq 6 ]
  [[ "$output" == *"1:"*"目だった。"* ]]
  [[ "$output" == *"5:"*"声だった。"* ]]
}

@test "scene-check.sh lists negative narration sentences, not dialogue or thoughts" {
  printf '　返事はなかった。\n「知らない。帰れ」\n　廊下には誰もいない。\n『来ない。』\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/scene-check.sh" story/010.txt
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c '^- ')" -eq 6 ]
  [[ "$output" == *"1:"*"返事はなかった。"* ]]
  [[ "$output" == *"3:"*"誰もいない。"* ]]
  [[ "$output" != *"知らない"* ]]
  [[ "$output" != *"来ない"* ]]
}

@test "scene-check.sh fails on a missing file" {
  run sh "$BATS_TEST_DIRNAME/scene-check.sh" story/missing.txt
  [ "$status" -eq 1 ]
}
