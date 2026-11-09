#!/usr/bin/env bats
# length.sh — whether the story file is shorter than the length the plot's 分量 gives.

setup() {
  LEN="$BATS_TEST_DIRNAME/length.sh"
  cd "$BATS_TEST_TMPDIR" || exit
  printf '　彼は頷いた。\n「終わり」\n\n' > story.txt
}

plot() {
  printf '本文\n\n## 分量\n%b\n## 禁止事項\n99999字\n' "$1" > plot.md
}

@test "length.sh counts 字 without whitespace over the whole file" {
  plot '12字\n'
  run sh "$LEN" plot.md story.txt
  [ "$status" -eq 0 ]
  [ "$output" = "11/12字" ]
}

@test "length.sh prints nothing for a file at its length" {
  plot '11字\n'
  run sh "$LEN" plot.md story.txt
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "length.sh counts words" {
  printf 'He nodded and left the room.\n' > en.txt
  plot '7 words\n'
  run sh "$LEN" plot.md en.txt
  [ "$status" -eq 0 ]
  [ "$output" = "6/7 words" ]
  plot '6 words\n'
  run sh "$LEN" plot.md en.txt
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "length.sh prints nothing for a plot with no length" {
  plot ''
  run sh "$LEN" plot.md story.txt
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  printf '本文\n' > plot.md
  run sh "$LEN" plot.md story.txt
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "length.sh needs the plot and the story file" {
  plot ''
  run sh "$LEN" plot.md
  [ "$status" -eq 2 ]
  run sh "$LEN" plot.md missing.txt
  [ "$status" -eq 1 ]
  [[ "$output" == *"save the text there"* ]]
}
