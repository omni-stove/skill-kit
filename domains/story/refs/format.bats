#!/usr/bin/env bats
# format.sh — indentation, ……, ― pairs, ｜, **bold**, 。」, ！／？ spacing and the * separator and the blank lines around it fixed in place; the other mechanical format rules and a stray 【】, listed by rule.

setup() {
  FORMAT="$BATS_TEST_DIRNAME/format.sh"
  f="$BATS_TEST_TMPDIR/010.txt"
}

@test "format.sh prints nothing for a clean file, header included" {
  printf 'Subhead: 太郎\nMemo: story/plot/010-a.md\n\n　|太郎《たろう》は走った――そして、止まった。\n「行くぞ！　早く」\n「え？」\n\n*\n\n『まさか！』\n　部屋は三つ、〇・五階。\n' > "$f"
  run sh "$FORMAT" "$f"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "format.sh fixes indentation in place: bare narration, indented dialogue, double and half-width indent" {
  printf 'Memo: story/plot/010-a.md\n\n彼は頷いた。\n　「字下げ」\n　　二重。\n  半角。\n　正しい。\n\n　*\n\n『思考』\n' > "$f"
  run sh "$FORMAT" "$f"
  [ "$status" -eq 0 ]
  [[ "$output" == *"fixed 5 line(s)"* ]]
  [ "$(cat "$f")" = "$(printf 'Memo: story/plot/010-a.md\n\n　彼は頷いた。\n「字下げ」\n　二重。\n　半角。\n　正しい。\n\n*\n\n『思考』\n')" ]
}

@test "format.sh leaves a Memo:, Subhead:, Lead: and Source: header untouched, blank lines included" {
  printf 'Memo: plot/010.md\nSubhead: 太郎\nLead: 「言葉」——誰か\n\nSource: 誰か\n【】\n　本文。\n' > "$f"
  before=$(cat "$f")
  run sh "$FORMAT" "$f"
  [ -z "$output" ]
  [ "$before" = "$(cat "$f")" ]
}

@test "format.sh formats any other Key: value line as body" {
  printf 'Title: 題\n\n　本文。\n' > "$f"
  run sh "$FORMAT" "$f"
  [ "$(cat "$f")" = "$(printf '　Title: 題\n\n　本文。\n')" ]
}

@test "format.sh turns a line of * or ◇ alone into *" {
  printf '　一。\n\n　* * *\n\n　二。\n\n***\n\n　三。\n\n◇◇◇\n\n　四。\n' > "$f"
  run sh "$FORMAT" "$f"
  [ "$(cat "$f")" = "$(printf '　一。\n\n*\n\n　二。\n\n*\n\n　三。\n\n*\n\n　四。\n')" ]
  [ "$output" = "format: fixed 3 line(s) of $f" ]
}

@test "format.sh lists a 【】 past the first body line" {
  printf 'Subhead: 太郎\n【】\n　一。\n【】\n' > "$f"
  run sh "$FORMAT" "$f"
  [[ "$output" == *"【】 past"*"4:【】"* ]]
  [[ "$output" != *"2:"* ]]
}

@test "format.sh strips the indent from lines opening with （, 【, 〖, 〔, ［, 〈 or 《" {
  printf '　（まさか）\n　【警告】\n〖称号〗\n　〔注〕\n　［選択］\n　〈声〉\n　《念話》\n' > "$f"
  run sh "$FORMAT" "$f"
  [ "$status" -eq 0 ]
  [ "$(cat "$f")" = "$(printf '（まさか）\n【警告】\n〖称号〗\n〔注〕\n［選択］\n〈声〉\n《念話》\n')" ]
}

@test "format.sh leaves a correctly indented file untouched" {
  printf '　一。\n「二」\n' > "$f"
  before=$(ls -li "$f"; cat "$f")
  run sh "$FORMAT" "$f"
  [ -z "$output" ]
  [ "$before" = "$(ls -li "$f"; cat "$f")" ]
}

@test "format.sh puts a blank line on each side of a separator and lists blank lines away from it" {
  printf '　一。\n\n　二。\n* * *\n　三。\n' > "$f"
  run sh "$FORMAT" "$f"
  [ "$(cat "$f")" = "$(printf '　一。\n\n　二。\n\n*\n\n　三。\n')" ]
  [[ "$output" == *"blank line"*"2:"* ]]
  [[ "$output" != *"4:"* ]]
}

@test "format.sh tells a separator from other bracket-only lines in a UTF-8 locale" {
  printf '【】\n　一。\n' > "$f"
  LC_ALL=ja_JP.UTF-8 run sh "$FORMAT" "$f"
  [ "$(cat "$f")" = "$(printf '【】\n　一。\n')" ]
}

@test "format.sh lists a separator at either end of the file" {
  printf '*\n　一。\n*\n' > "$f"
  run sh "$FORMAT" "$f"
  [[ "$output" == *"separator"*"1:*"*"5:*"* ]]
}

@test "format.sh lists dialogue sharing its line" {
  printf '「行くぞ」と彼は言った。\n' > "$f"
  run sh "$FORMAT" "$f"
  [[ "$output" == *"1:「行くぞ」と"* ]]
}

@test "format.sh fixes …… to ――, drops the period closing dialogue, and spaces ！／？" {
  printf '　次は……だ。\n「終わり。」\n　だめ！次へ。嘘？ 本当。\n「本当！？　嘘だ！」\n「なに？――」\n（まさか！）叫んだ！\n' > "$f"
  run sh "$FORMAT" "$f"
  [ "$status" -eq 0 ]
  [ "$output" = "format: fixed 3 line(s) of $f" ]
  [ "$(cat "$f")" = "$(printf '　次は――だ。\n「終わり」\n　だめ！　次へ。嘘？　本当。\n「本当！？　嘘だ！」\n「なに？――」\n（まさか！）叫んだ！\n')" ]
}

@test "format.sh turns — and ─ into ― and pairs an odd run of ―" {
  printf '　三―四。\n　三――四。\n　三―――四。\n　三——四。\n　三──四。\n' > "$f"
  run sh "$FORMAT" "$f"
  [ "$status" -eq 0 ]
  [ "$(cat "$f")" = "$(printf '　三――四。\n　三――四。\n　三――――四。\n　三――四。\n　三――四。\n')" ]
}

@test "format.sh lists arabic numerals, half- and full-width" {
  printf '　部屋は3つ。\n　５階。\n' > "$f"
  run sh "$FORMAT" "$f"
  [[ "$output" == *"1:"*"2:"* ]]
}

@test "format.sh fixes a full-width ｜ and lists ruby without the | opener" {
  printf '　太郎《たろう》。\n　｜花子《はなこ》。\n　|次郎《じろう》。\n' > "$f"
  run sh "$FORMAT" "$f"
  [ "$(sed -n 2p "$f")" = '　|花子《はなこ》。' ]
  [[ "$output" == *"1:"* ]]
  [[ "$output" != *"2:"* ]]
  [[ "$output" != *"3:"* ]]
}

@test "format.sh strips **bold** and lists other markdown" {
  printf '# 見出し\n　**強調**した。\n' > "$f"
  run sh "$FORMAT" "$f"
  [ "$(sed -n 2p "$f")" = '　強調した。' ]
  [[ "$output" == *"markdown"*"1:　# 見出し"* ]]
  [[ "$output" != *"2:"* ]]
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
