#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031 # each @test runs in its own subshell, and run sets $output afresh in each
# source.sh — deterministic resolution of the source and its output file; scene.sh — the writing step, held until the report is saved; scene-check.sh — the format fix and the checks before each hand-off; check.sh — the format fix and the whole-file checks over the finished file.

setup() {
  SOURCE="$BATS_TEST_DIRNAME/source.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story/plot" "$work/sub/plot"
  cd "$work" || exit
  printf '# 作品\n## 舞台\n港町\n' > README.md
}

@test "source.sh writes plot/<x>.md to the dir holding plot, named by the leading number" {
  : > story/plot/010-co-arrival.md
  run sh "$SOURCE" story/plot/010-co-arrival.md
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Output: story/010.txt" ]
}

@test "source.sh names the output after the whole stem when there is no leading number" {
  : > story/plot/arrival.md
  run sh "$SOURCE" story/plot/arrival.md
  [ "${lines[0]}" = "Output: story/arrival.txt" ]
}

@test "source.sh keeps the plot dir's parent for a nested plot" {
  : > sub/plot/020.md
  run sh "$SOURCE" sub/plot/020.md
  [ "${lines[0]}" = "Output: sub/020.txt" ]
}

@test "source.sh writes plot.md to index.txt beside it" {
  : > sub/plot.md
  run sh "$SOURCE" sub/plot.md
  [ "${lines[0]}" = "Output: sub/index.txt" ]
}

@test "source.sh writes another .md to <stem>.txt beside it" {
  : > story/03.md
  run sh "$SOURCE" story/03.md
  [ "${lines[0]}" = "Output: story/03.txt" ]
}

@test "source.sh revises a .txt in place" {
  : > story/010.txt
  run sh "$SOURCE" story/010.txt
  [ "${lines[0]}" = "Output: story/010.txt" ]
  [[ "$output" == *"revise it"* ]]
  [[ "$output" == *'scene-check.sh "story/010.txt"'* ]]
  [[ "$output" == *'others.sh --earlier "story/010.txt"'* ]]
}

@test "source.sh goes straight to the report when the output is missing" {
  : > story/plot/arrival.md
  run sh "$SOURCE" story/plot/arrival.md
  [[ "$output" != *"Read the output file, ask"* ]]
  [[ "$output" == *'others.sh --earlier "story/plot/arrival.md"'* ]]
  [[ "$output" == *'scene.sh "story/plot/arrival.md" "story/arrival.txt" <the report file>'* ]]
  [[ "$output" != *"Write 1 Scene"* ]]
}

@test "source.sh prints a Reference line for each setting file the plot references" {
  printf '本文\n\n## Prohibited\n- @story/not-this.md\n\n## References\n- @story/characters/aki.md\n- @story/world/port.md\n' > story/plot/010-co-arrival.md
  run sh "$SOURCE" story/plot/010-co-arrival.md
  [[ "$output" == *$'Reference: story/characters/aki.md\nReference: story/world/port.md'* ]]
  [[ "$output" != *"not-this"* ]]
  : > story/010.txt
  run sh "$SOURCE" story/010.txt
  [[ "$output" == *"Reference: story/characters/aki.md"* ]]
  [[ "$output" == *"revise it"* ]]
}

@test "scene.sh prints the writing step only once the report is saved" {
  : > story/plot/arrival.md
  run sh "$BATS_TEST_DIRNAME/scene.sh" story/plot/arrival.md story/arrival.txt report.txt
  [ "$status" -eq 1 ]
  [[ "$output" == *"wait for the Agent's report"* ]]
  [[ "$output" != *"Write 1 Scene"* ]]
  : > report.txt
  run sh "$BATS_TEST_DIRNAME/scene.sh" story/plot/arrival.md story/arrival.txt report.txt
  [ "$status" -eq 1 ]
  printf 'レポート\n' > report.txt
  run sh "$BATS_TEST_DIRNAME/scene.sh" story/plot/arrival.md story/arrival.txt report.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *"Write 1 Scene"* ]]
  [[ "$output" == *'scene-check.sh "story/plot/arrival.md" "story/arrival.txt" "report.txt"'* ]]
}

@test "source.sh says to read and ask when the output exists" {
  : > story/plot/010-co-arrival.md
  : > story/010.txt
  run sh "$SOURCE" story/plot/010-co-arrival.md
  [[ "$output" == *"Read the output file, ask"* ]]
}

@test "refs.sh adds author-rules.md after the default rules only when it exists" {
  mkdir -p .agents/refs
  for r in japanese-web-novel-sentence-guard japanese-web-novel-narration-guard; do echo "$r" > ".agents/refs/$r.md"; done
  echo lead > .agents/refs/author-override.md
  run sh "$BATS_TEST_DIRNAME/../refs.sh"
  [ "$status" -eq 0 ]
  [[ "$output" != *lead* ]]
  echo mine > author-rules.md
  run sh "$BATS_TEST_DIRNAME/../refs.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *narration-guard*lead*mine* ]]
}

@test "check.sh prints the whole-file checks and the hand-off" {
  printf '　彼は頷いた。\n' > story/010.txt
  : > story/plot/arrival.md
  run sh "$BATS_TEST_DIRNAME/check.sh" story/plot/arrival.md story/010.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *"Where the same wording appears twice"*"[Output file] complete."* ]]
  [[ "$output" != *"だった"* ]]
}

@test "source.sh fails on a missing source" {
  run sh "$SOURCE" story/plot/missing.md
  [ "$status" -eq 1 ]
}

@test "scene-check.sh prints the five whole-file checks and hands the finished file to check.sh" {
  printf '　彼は頷いた。\n' > story/010.txt
  : > story/plot/arrival.md
  run sh "$BATS_TEST_DIRNAME/scene-check.sh" story/plot/arrival.md story/010.txt report.txt
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c '^- ')" -eq 5 ]
  [[ "$output" == *"[Scene name] complete."* ]]
  [[ "$output" == *'check.sh "story/plot/arrival.md" "story/010.txt" "report.txt" instead'* ]]
  [[ "$output" == *'then run '*'scene-check.sh "story/plot/arrival.md" "story/010.txt" "report.txt".'* ]]
  run sh "$BATS_TEST_DIRNAME/scene-check.sh" story/010.txt story/010.txt
  [[ "$output" == *"[Output file] revised."* ]]
  [[ "$output" == *'y: run '*'check.sh "story/010.txt" "story/010.txt"'* ]]
  [[ "$output" == *'then run '*'scene-check.sh "story/010.txt" "story/010.txt".'* ]]
  [[ "$output" != *"next Scene"* ]]
}

@test "check.sh lists narration sentences ending on the copula, not dialogue, " {
  printf '　彼は頷いた。覚悟を決めた目だった。\n「嘘だった」\n　静かな夜だった。\n　鍵は古い真鍮のようだった。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/check.sh" story/010.txt story/010.txt
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c '^- ')" -eq 4 ]
  [[ "$output" == *"1:"*"目だった。"* ]]
  [[ "$output" == *"3:"*"夜だった。"* ]]
  [[ "$output" == *"4:"*"ようだった。"* ]]
  [[ "$output" != *"嘘だった"* ]]
}

@test "scene-check.sh lists negative narration sentences, not dialogue or thoughts" {
  printf '　返事はなかった。\n「知らない。帰れ」\n　廊下には誰もいない。\n『来ない。』\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/scene-check.sh" story/010.txt story/010.txt
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c '^- ')" -eq 6 ]
  [[ "$output" == *"1:"*"返事はなかった。"* ]]
  [[ "$output" == *"3:"*"誰もいない。"* ]]
  [[ "$output" != *"知らない"* ]]
  [[ "$output" != *"来ない"* ]]
}

@test "scene-check.sh lists narration set against a denied alternative, apart from negatives and not dialogue" {
  printf '　離さないのではなく、離せないのだ。\n　落ちたのは尾根からではなかった。\n　怒鳴るというより、押し出すようだった。\n　棚田でも餅でもなく、社を見に来た。\n　任されたのとは違う。\n　道を教えていたわけではないだろう。\n「敵ではなく味方だ」\n　臼をどかすまでもなく、わかった。\n　残念がるでもなく繰り返した。\n　返事はなかった。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/scene-check.sh" story/010.txt story/010.txt
  [ "$status" -eq 0 ]
  listed=$(printf '%s\n' "$output" | sed -n '/denies or discounts/,/negative narration sentence/p')
  [ "$(printf '%s\n' "$listed" | grep -cE '^[0-9]+:')" -eq 6 ]
  [[ "$listed" == *"1:"*"2:"*"3:"*"4:"*"5:"*"6:"* ]]
  [[ "$listed" != *"味方だ"* ]]
  [[ "$listed" != *"臼を"* ]]
  [[ "$listed" != *"残念がる"* ]]
  [[ "$listed" != *"返事は"* ]]
  negatives=$(printf '%s\n' "$output" | sed -n '/negative narration sentence/,$p')
  [[ "$negatives" == *"10:"*"返事はなかった。"* ]]
  [[ "$negatives" != *"尾根"* ]]
}

@test "scene-check.sh lists narration describing a voice or sound, not dialogue or lookalike words" {
  printf '　しゃがれた声が続いた。\n　金具が小さな音を立てた。\n　声は平らだった。\n　声が尖った。\n　怒っているのだと、声の低さでわかった。\n「低い声で言え」\n　笑い声が上がった。\n　銃声は続いた。\n　また声がした。\n　彼は頷いた。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/scene-check.sh" story/010.txt story/010.txt
  [ "$status" -eq 0 ]
  listed=$(printf '%s\n' "$output" | sed -n '/how a voice or sound sounds/,/Then reply/p')
  [ "$(printf '%s\n' "$listed" | grep -cE '^[0-9]+:')" -eq 5 ]
  [[ "$listed" == *"1:"*"2:"*"3:"*"4:"*"5:"* ]]
  [[ "$listed" != *"低い声で言え"* ]]
  [[ "$listed" != *"笑い声"* ]]
  [[ "$listed" != *"銃声"* ]]
  [[ "$listed" != *"また声"* ]]
}

@test "scene-check.sh and check.sh fail on a missing file" {
  run sh "$BATS_TEST_DIRNAME/scene-check.sh" story/missing.txt story/missing.txt
  [ "$status" -eq 1 ]
  run sh "$BATS_TEST_DIRNAME/check.sh" story/missing.txt story/missing.txt
  [ "$status" -eq 1 ]
}

@test "scene-check.sh fixes the format and lists the lines that break a format rule" {
  printf '彼は頷いた。\n「終わり。」\n「行く」と言った。\n　部屋は3つ……。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/scene-check.sh" story/010.txt story/010.txt
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c '^- ')" -eq 6 ]
  [ "$(head -2 story/010.txt)" = "$(printf '　彼は頷いた。\n「終わり」\n')" ]
  [[ "$output" == *"3:「行く」と言った。"* ]]
  [[ "$output" != *"部屋は3つ"* ]]
  [ "$(sed -n 4p story/010.txt)" = "　部屋は3つ……。" ]
}
