#!/usr/bin/env bats
# references.sh — the setting files a plot's ## References names.

setup() {
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story/plot"
  cd "$work" || exit
  printf '本文\n\n## Prohibited\n- @story/not-this.md\n\n## References\n- @story/characters/aki.md\n- @story/world/port.md\n\n## Dialogue\n- @story/nor-this.md\n' > story/plot/010-co-arrival.md
}

@test "references.sh prints the paths under the plot's ## References alone" {
  run sh "$BATS_TEST_DIRNAME/references.sh" story/plot/010-co-arrival.md
  [ "$status" -eq 0 ]
  [ "$output" = $'story/characters/aki.md\nstory/world/port.md' ]
}

@test "references.sh reads the plot paired with a story file" {
  : > story/010.txt
  : > story/020.txt
  run sh "$BATS_TEST_DIRNAME/references.sh" story/010.txt
  [ "$output" = $'story/characters/aki.md\nstory/world/port.md' ]
  run sh "$BATS_TEST_DIRNAME/references.sh" story/020.txt
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "references.sh fails on a missing file" {
  run sh "$BATS_TEST_DIRNAME/references.sh" story/plot/none.md
  [ "$status" -eq 1 ]
}
