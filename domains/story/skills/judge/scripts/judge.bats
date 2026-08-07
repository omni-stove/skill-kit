#!/usr/bin/env bats
# opening.sh — deterministic selection of the manuscript's opening files.

setup() {
  OPENING="$BATS_TEST_DIRNAME/opening.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story"
  cd "$work"
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

@test "opening.sh stops after the file that crosses 15,000 chars" {
  fill story/01.txt 8000
  fill story/02.txt 8000
  fill story/03.txt 8000
  run sh "$OPENING" story
  [ "${#lines[@]}" -eq 2 ]
  [ "${lines[1]##*/}" = "02.txt" ]
}

@test "opening.sh skips synopsis and dotfiles" {
  fill story/synopsis.txt 10
  fill story/.hidden 10
  fill story/chapter.txt 10
  run sh "$OPENING" story
  [ "${#lines[@]}" -eq 1 ]
  [ "${lines[0]##*/}" = "chapter.txt" ]
}
