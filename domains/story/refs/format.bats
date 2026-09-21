#!/usr/bin/env bats
# format.sh — indentation, ……, 。」 and ！／？ spacing fixed in place; the other mechanical format rules, listed by rule.

setup() {
  FORMAT="$BATS_TEST_DIRNAME/format.sh"
  f="$BATS_TEST_TMPDIR/010.txt"
}

@test "format.sh prints nothing for a clean file, header included" {
  printf 'Source: story/plot/010-a.md\nPOV: 太郎\n\n　|太郎《たろう》は走った――そして、止まった。\n「行くぞ！　早く」\n「え？」\n\n◇◇◇\n\n『まさか！』\n　部屋は三つ、〇・五階。\n' > "$f"
  run sh "$FORMAT" "$f"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "format.sh fixes indentation in place: bare narration, indented dialogue, double and half-width indent" {
  printf 'Source: story/plot/010-a.md\n\n彼は頷いた。\n　「字下げ」\n　　二重。\n  半角。\n　正しい。\n\n　◇◇◇\n\n『思考』\n' > "$f"
  run sh "$FORMAT" "$f"
  [ "$status" -eq 0 ]
  [[ "$output" == *"fixed 5 line(s)"* ]]
  [ "$(cat "$f")" = "$(printf 'Source: story/plot/010-a.md\n\n　彼は頷いた。\n「字下げ」\n　二重。\n　半角。\n　正しい。\n\n◇◇◇\n\n『思考』\n')" ]
}

@test "format.sh leaves a correctly indented file untouched" {
  printf '　一。\n「二」\n' > "$f"
  before=$(ls -li "$f"; cat "$f")
  run sh "$FORMAT" "$f"
  [ -z "$output" ]
  [ "$before" = "$(ls -li "$f"; cat "$f")" ]
}

@test "format.sh lists blank lines away from the separator and a separator without them" {
  printf '　一。\n\n　二。\n◇◇◇\n　三。\n' > "$f"
  run sh "$FORMAT" "$f"
  [[ "$output" == *"blank line"*"2:"* ]]
  [[ "$output" == *"4:◇◇◇"* ]]
}

@test "format.sh lists dialogue sharing its line" {
  printf '「行くぞ」と彼は言った。\n' > "$f"
  run sh "$FORMAT" "$f"
  [[ "$output" == *"1:「行くぞ」と"* ]]
}

@test "format.sh fixes …… to ――, drops the period closing dialogue, and spaces ！／？" {
  printf '　次は……だ。\n「終わり。」\n　だめ！次へ。嘘？ 本当。\n「本当！？　嘘だ！」\n「なに？――」\n　（まさか！）叫んだ！\n' > "$f"
  run sh "$FORMAT" "$f"
  [ "$status" -eq 0 ]
  [ "$output" = "format: fixed 3 line(s) of $f" ]
  [ "$(cat "$f")" = "$(printf '　次は――だ。\n「終わり」\n　だめ！　次へ。嘘？　本当。\n「本当！？　嘘だ！」\n「なに？――」\n　（まさか！）叫んだ！\n')" ]
}

@test "format.sh lists an unpaired ―" {
  printf '　三―四。\n　三――四。\n' > "$f"
  run sh "$FORMAT" "$f"
  [[ "$output" == *"1:　三―四。"* ]]
  [[ "$output" != *"2:"* ]]
}

@test "format.sh lists arabic numerals, half- and full-width" {
  printf '　部屋は3つ。\n　５階。\n' > "$f"
  run sh "$FORMAT" "$f"
  [[ "$output" == *"1:"*"2:"* ]]
}

@test "format.sh lists ruby without the | opener or with a full-width ｜" {
  printf '　太郎《たろう》。\n　｜花子《はなこ》。\n　|次郎《じろう》。\n' > "$f"
  run sh "$FORMAT" "$f"
  [[ "$output" == *"1:"*"2:"* ]]
  [[ "$output" != *"3:"* ]]
}

@test "format.sh lists markdown" {
  printf '# 見出し\n　**強調**した。\n' > "$f"
  run sh "$FORMAT" "$f"
  [[ "$output" == *"markdown"*"1:　# 見出し"*"2:"* ]]
}

@test "format.sh gives the same list in the C locale" {
  printf '彼は頷いた。\n　太郎《たろう》と三―四！次。\n' > "$f"
  cp "$f" "$f.c"
  utf=$(sh "$FORMAT" "$f" 2>/dev/null)
  c=$(LC_ALL=C sh "$FORMAT" "$f.c" 2>/dev/null | sed 's/\.c$//')
  [ -n "$utf" ] && [ "$utf" = "$c" ]
  cmp "$f" "$f.c"
}

@test "format.sh fails on a missing file" {
  run sh "$FORMAT" "$BATS_TEST_TMPDIR/missing.txt"
  [ "$status" -eq 1 ]
}
