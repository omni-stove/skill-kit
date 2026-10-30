#!/usr/bin/env bats
# opening.sh — deterministic selection of the manuscript's opening files.

setup() {
  OPENING="$BATS_TEST_DIRNAME/opening.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story"
  cd "$work" || exit
}

fill() { head -c "$2" /dev/zero | tr '\0' 'a' > "$1"; }

@test "opening.sh lists files in natural order" {
  fill story/1.txt 10
  fill story/10.txt 10
  fill story/2.txt 10
  run sh "$OPENING" story
  [ "$status" -eq 0 ]
  [ "${lines[0]##*/}" = "1.txt" ]
  [ "${lines[1]##*/}" = "2.txt" ]
  [ "${lines[2]##*/}" = "10.txt" ]
}

@test "opening.sh stops on the total closest to 10,000 — undershooting" {
  fill story/01.txt 6000
  fill story/02.txt 3000
  fill story/03.txt 6000
  run sh "$OPENING" story
  [ "$(printf '%s\n' "$output" | grep -c '\.txt$')" -eq 2 ]
  [ "${lines[1]##*/}" = "02.txt" ]
}

@test "opening.sh stops on the total closest to 10,000 — overshooting" {
  fill story/01.txt 6000
  fill story/02.txt 3000
  fill story/03.txt 1500
  run sh "$OPENING" story
  [ "$(printf '%s\n' "$output" | grep -c '\.txt$')" -eq 3 ]
  [ "${lines[2]##*/}" = "03.txt" ]
}

@test "opening.sh always prints the first file, however long" {
  fill story/01.txt 50000
  fill story/02.txt 100
  run sh "$OPENING" story
  [ "$(printf '%s\n' "$output" | grep -c '\.txt$')" -eq 1 ]
  [ "${lines[0]##*/}" = "01.txt" ]
}

@test "opening.sh skips synopsis and dotfiles" {
  fill story/synopsis.txt 10
  fill story/.hidden 10
  fill story/chapter.txt 10
  run sh "$OPENING" story
  [ "$(printf '%s\n' "$output" | grep -c '\.txt$')" -eq 1 ]
  [ "${lines[0]##*/}" = "chapter.txt" ]
  [[ "$output" == *"first-round screening"* ]]
}
