#!/usr/bin/env bats
# translation-pairs.sh — pair resolution and the plot line.

setup() {
  PAIRS="$BATS_TEST_DIRNAME/translation-pairs.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story/en" "$work/story/plot"
  cd "$work"
}

@test "prints a pair line for a source with a translation" {
  : > story/010.txt
  : > story/en/010.txt
  run sh "$PAIRS" story/010.txt
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "$(printf 'pair\tstory/010.txt\tstory/en/010.txt')" ]
}

@test "prints no plot line when the source has no plot" {
  : > story/010.txt
  run sh "$PAIRS" story/010.txt
  [ "$status" -eq 0 ]
  [[ "$output" != *plot* ]]
}

@test "resolves the plot from the source's leading Source: line" {
  echo "Source: story/plot/arrival.md" > story/010.txt
  : > story/plot/arrival.md
  run sh "$PAIRS" story/010.txt
  [ "${lines[2]}" = "$(printf 'plot\tstory/010.txt\tstory/plot/arrival.md')" ]
}

@test "resolves the plot by its leading number when there is no Source: line" {
  : > story/010.txt
  : > story/plot/010-co-arrival.md
  run sh "$PAIRS" story/010.txt
  [ "${lines[2]}" = "$(printf 'plot\tstory/010.txt\tstory/plot/010-co-arrival.md')" ]
}

@test "resolves the plot by its whole stem when it has no leading number" {
  : > story/arrival.txt
  : > story/plot/arrival.md
  run sh "$PAIRS" story/arrival.txt
  [ "${lines[2]}" = "$(printf 'plot\tstory/arrival.txt\tstory/plot/arrival.md')" ]
}

@test "resolves the plot for an en/ path" {
  : > story/010.txt
  : > story/en/010.txt
  : > story/plot/010-co-arrival.md
  run sh "$PAIRS" story/en/010.txt
  [ "${lines[2]}" = "$(printf 'plot\tstory/010.txt\tstory/plot/010-co-arrival.md')" ]
}

@test "prints a plot line after each source in a directory listing" {
  : > story/010.txt
  : > story/020.txt
  : > story/plot/020-return.md
  run sh "$PAIRS" story
  [ "${lines[1]}" = "$(printf 'source-only\tstory/010.txt\tstory/en/010.txt')" ]
  [ "${lines[2]}" = "$(printf 'source-only\tstory/020.txt\tstory/en/020.txt')" ]
  [ "${lines[3]}" = "$(printf 'plot\tstory/020.txt\tstory/plot/020-return.md')" ]
}
