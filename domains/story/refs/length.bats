#!/usr/bin/env bats
# length.sh — the events shorter than the minimum the plot's 分量 gives them.

setup() {
  LEN="$BATS_TEST_DIRNAME/length.sh"
  cd "$BATS_TEST_TMPDIR" || exit
  printf '　彼は頷いた。\n「終わり」\n\nHe nodded and left the room.\n' > story.txt
}

plot() {
  printf '本文\n\n## 分量\n%b\n## 禁止事項\n- 12字\n' "$1" > plot.md
}

@test "length.sh counts 字 without whitespace and lists an event under its minimum" {
  plot '- 対決: 12字\n'
  run sh "$LEN" plot.md story.txt 1-3
  [ "$status" -eq 0 ]
  [ "$output" = "対決: 11/12字" ]
}

@test "length.sh prints nothing for an event at its minimum" {
  plot '- 対決: 11字\n'
  run sh "$LEN" plot.md story.txt 1-3
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "length.sh counts words, in the order the plot lists the events" {
  plot '- 対決: 1字\n- The exit: 7 words\n- One word: 1 word\n'
  run sh "$LEN" plot.md story.txt 1-1 4-4 4-4
  [ "$status" -eq 0 ]
  [ "$output" = "The exit: 6/7 words" ]
}

@test "length.sh skips the events marked to pass over and a plot with no length" {
  plot '- 移動: 流す\n- Travel: brief\n'
  run sh "$LEN" plot.md story.txt
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  printf '本文\n' > plot.md
  run sh "$LEN" plot.md story.txt
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "length.sh needs one range per event" {
  plot '- 対決: 12字\n'
  run sh "$LEN" plot.md story.txt
  [ "$status" -eq 1 ]
  [[ "$output" == *"1 event(s)"*"0 line range(s)"* ]]
}

@test "length.sh refuses a range the story file does not hold" {
  plot '- 対決: 12字\n'
  for bad in 1 3-1 1-99 a-b 0-1; do
    run sh "$LEN" plot.md story.txt "$bad"
    [ "$status" -eq 1 ]
    [[ "$output" == *"is not a line range"* ]]
  done
}

@test "length.sh needs the plot and the story file" {
  plot ''
  run sh "$LEN" plot.md
  [ "$status" -eq 2 ]
  run sh "$LEN" plot.md missing.txt
  [ "$status" -eq 1 ]
  [[ "$output" == *"save the text there"* ]]
}
