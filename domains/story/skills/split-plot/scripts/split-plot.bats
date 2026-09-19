#!/usr/bin/env bats
# paths.sh — deterministic output paths for the split segments.

setup() {
  PATHS="$BATS_TEST_DIRNAME/paths.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story/plot"
  cd "$work"
}

@test "paths.sh numbers from 010 by tens in an empty story/plot/" {
  run sh "$PATHS" co arrival first-night
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "story/plot/010-co-arrival.md" ]
  [ "${lines[1]}" = "story/plot/020-co-first-night.md" ]
}

@test "paths.sh numbers from 010 when story/plot/ is missing" {
  rmdir story/plot
  run sh "$PATHS" co arrival
  [ "${lines[0]}" = "story/plot/010-co-arrival.md" ]
}

@test "paths.sh continues from the next ten after the highest number" {
  : > story/plot/010-co-arrival.md
  : > story/plot/085-co-detour.md
  : > story/plot/memo.md
  run sh "$PATHS" co return
  [ "${lines[0]}" = "story/plot/090-co-return.md" ]
}

@test "paths.sh steps past a number already on a ten" {
  : > story/plot/090-co-return.md
  run sh "$PATHS" co epilogue
  [ "${lines[0]}" = "story/plot/100-co-epilogue.md" ]
}

@test "paths.sh rejects a slug that is not kebab-case" {
  run sh "$PATHS" co "First Night"
  [ "$status" -eq 1 ]
}

@test "paths.sh needs a base and at least one slug" {
  run sh "$PATHS" co
  [ "$status" -eq 2 ]
}
