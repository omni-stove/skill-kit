#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031 # each @test runs in its own subshell, and run sets $output afresh in each
# source.sh — deterministic resolution of the source and its output file; write.sh — the writing step, held until the report is saved; check.sh — the guards, the format fix and the checks before each hand-off.

setup() {
  SOURCE="$BATS_TEST_DIRNAME/source.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story/plot" "$work/sub/plot"
  cd "$work" || exit
  printf '# 作品\n## 舞台\n港町\n' > README.md
  mkdir -p .agents/refs
  for r in japanese-web-novel-sentence-guard japanese-web-novel-narration-guard; do echo "$r" > ".agents/refs/$r.md"; done
  echo override > .agents/refs/author-override.md
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
  [[ "$output" == *'check.sh "story/010.txt" "story/010.txt"'* ]]
  [[ "$output" == *'others.sh --earlier "story/010.txt"'* ]]
}

@test "source.sh goes straight to the report when the output is missing" {
  : > story/plot/arrival.md
  run sh "$SOURCE" story/plot/arrival.md
  [[ "$output" != *'Ask "Overwrite it?"'* ]]
  [[ "$output" == *'others.sh --earlier "story/plot/arrival.md"'* ]]
  [[ "$output" == *'write.sh "story/plot/arrival.md" "story/arrival.txt" <the report file>'* ]]
  [[ "$output" != *"Write every Scene"* ]]
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

@test "write.sh prints the writing step only once the report is saved" {
  : > story/plot/arrival.md
  run sh "$BATS_TEST_DIRNAME/write.sh" story/plot/arrival.md story/arrival.txt report.txt
  [ "$status" -eq 1 ]
  [[ "$output" == *"wait for the Agent's report"* ]]
  [[ "$output" != *"Write every Scene"* ]]
  : > report.txt
  run sh "$BATS_TEST_DIRNAME/write.sh" story/plot/arrival.md story/arrival.txt report.txt
  [ "$status" -eq 1 ]
  printf 'レポート\n' > report.txt
  run sh "$BATS_TEST_DIRNAME/write.sh" story/plot/arrival.md story/arrival.txt report.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *"Write every Scene of story/plot/arrival.md"*"save them to story/arrival.txt"* ]]
  [[ "$output" == *'check.sh "story/plot/arrival.md" "story/arrival.txt" "report.txt"'* ]]
}

@test "source.sh says to read and ask when the output exists" {
  : > story/plot/010-co-arrival.md
  : > story/010.txt
  run sh "$SOURCE" story/plot/010-co-arrival.md
  [[ "$output" == *'Ask "Overwrite it?"'* ]]
}

@test "check.sh prints the guards before the checks, with author-rules.md after them only when it exists" {
  printf '　彼は頷いた。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/check.sh" story/010.txt story/010.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *sentence-guard*narration-guard*"Read the whole output file"*"[Output file] complete."* ]]
  [[ "$output" != *override* ]]
  echo mine > author-rules.md
  run sh "$BATS_TEST_DIRNAME/check.sh" story/010.txt story/010.txt
  [[ "$output" == *narration-guard*override*mine*"Read the whole output file"* ]]
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

@test "check.sh hands off with a rerun on the same arguments" {
  printf '　彼は頷いた。\n' > story/010.txt
  : > story/plot/arrival.md
  : > report.txt
  run sh "$BATS_TEST_DIRNAME/check.sh" story/plot/arrival.md story/010.txt report.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *"[Output file] complete. Reply y to finish"* ]]
  [[ "$output" == *'then run '*'check.sh "story/plot/arrival.md" "story/010.txt" "report.txt".'* ]]
  run sh "$BATS_TEST_DIRNAME/check.sh" story/010.txt story/010.txt
  [[ "$output" == *'then run '*'check.sh "story/010.txt" "story/010.txt".'* ]]
}

@test "check.sh lists narration ending on the copula beside another, not across a paragraph or in dialogue" {
  printf '　彼は頷いた。覚悟を決めた目だった。\n「嘘だった」\n　静かな夜だった。\n\n　古い真鍮だった。\n　鍵は古いようだった。\n　鍵だった。冷たい鉄だった。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/check.sh" story/010.txt story/010.txt
  [ "$status" -eq 0 ]
  listed=$(printf '%s\n' "$output" | sed -n '/no two share a paragraph/,/Then reply/p')
  [ "$(printf '%s\n' "$listed" | grep -cE '^[0-9]+:')" -eq 3 ]
  [[ "$listed" == *"3:"*"5:"*"7:"* ]]
  [[ "$listed" != *"目だった"* ]]
  [[ "$listed" != *"ようだった"* ]]
  [[ "$output" != *"嘘だった"* ]]
}

@test "check.sh lists the narration ending a look or voice on the copula only when there is more than one" {
  printf '　覚悟を決めた目だった。\n　彼は頷いた。\n　乾いた声だった。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/check.sh" story/010.txt story/010.txt
  listed=$(printf '%s\n' "$output" | sed -n '/look or voice/,/Then reply/p')
  [[ "$listed" == *"1:"*"3:"* ]]
  printf '　覚悟を決めた目だった。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/check.sh" story/010.txt story/010.txt
  [[ "$output" != *"look or voice"* ]]
}

@test "check.sh lists negative narration sentences, not dialogue or thoughts" {
  printf '　返事はなかった。\n「知らない。帰れ」\n　廊下には誰もいない。\n『来ない。』\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/check.sh" story/010.txt story/010.txt
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c '^- ')" -eq 9 ]
  [[ "$output" == *"1:"*"返事はなかった。"* ]]
  [[ "$output" == *"3:"*"誰もいない。"* ]]
  [[ "$output" != *"知らない"* ]]
  [[ "$output" != *"来ない"* ]]
}

@test "check.sh lists the lines of four or more narration sentences in a row on the same ending, broken by dialogue or another ending" {
  printf '　女は顔を上げる。男が迫っている。\n　女は身をすくめる。男は飛んでいく。\n　空は晴れていた。風が吹いた。\n　彼は笑った。\n「行く。来る。見る。帰る」\n　犬が吠える。猫が逃げる。\n「待て」\n　鳥が鳴く。虫が跳ねる。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/check.sh" story/010.txt story/010.txt
  [ "$status" -eq 0 ]
  listed=$(printf '%s\n' "$output" | sed -n '/on the same form/,/^- /p' | grep -E '^[0-9]+:')
  [ "$(printf '%s\n' "$listed" | grep -c '^')" -eq 2 ]
  [[ "$listed" == *"1:"*"2:"* ]]
}

@test "check.sh lists narration set against a denied alternative, apart from negatives and not dialogue" {
  printf '　離さないのではなく、離せないのだ。\n　落ちたのは尾根からではなかった。\n　怒鳴るというより、押し出すようだった。\n　棚田でも餅でもなく、社を見に来た。\n　任されたのとは違う。\n　道を教えていたわけではないだろう。\n「敵ではなく味方だ」\n　臼をどかすまでもなく、わかった。\n　残念がるでもなく繰り返した。\n　返事はなかった。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/check.sh" story/010.txt story/010.txt
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

@test "check.sh lists narration describing a voice or sound, not dialogue or lookalike words" {
  printf '　しゃがれた声が続いた。\n　金具が小さな音を立てた。\n　声は平らだった。\n　声が尖った。\n　怒っているのだと、声の低さでわかった。\n「低い声で言え」\n　笑い声が上がった。\n　銃声は続いた。\n　また声がした。\n　彼は頷いた。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/check.sh" story/010.txt story/010.txt
  [ "$status" -eq 0 ]
  listed=$(printf '%s\n' "$output" | sed -n '/how a voice or sound sounds/,/^- /p')
  [ "$(printf '%s\n' "$listed" | grep -cE '^[0-9]+:')" -eq 5 ]
  [[ "$listed" == *"1:"*"2:"*"3:"*"4:"*"5:"* ]]
  [[ "$listed" != *"低い声で言え"* ]]
  [[ "$listed" != *"笑い声"* ]]
  [[ "$listed" != *"銃声"* ]]
  [[ "$listed" != *"また声"* ]]
}

@test "check.sh lists narration ending on the explanatory copula, not dialogue or thoughts" {
  printf '　彼は知っていたのだ。\n　それが答えだったのである。\n「行くのだ。急げ」\n『そうなのだ。』\n　彼は頷いた。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/check.sh" story/010.txt story/010.txt
  [ "$status" -eq 0 ]
  listed=$(printf '%s\n' "$output" | sed -n '/のだ or のである/,/Then reply/p')
  [ "$(printf '%s\n' "$listed" | grep -cE '^[0-9]+:')" -eq 2 ]
  [[ "$listed" == *"1:"*"2:"* ]]
  [[ "$listed" != *"急げ"* ]]
  [[ "$listed" != *"そうなのだ"* ]]
}

@test "check.sh lists lines attributing dialogue with a speech verb, not a quoted phrase" {
  printf '「聴くべきよ」と彼女は迷いのない声で言った。\n「それで」と私は続けた。\n　「歌」という言葉を思い出した。\n「行く」\n　彼は頷いた。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/check.sh" story/010.txt story/010.txt
  [ "$status" -eq 0 ]
  listed=$(printf '%s\n' "$output" | sed -n '/attributes dialogue with a speech verb/,/for what it is listed under/p')
  [ "$(printf '%s\n' "$listed" | grep -cE '^[0-9]+:')" -eq 2 ]
  [[ "$listed" == *"1:"*"2:"* ]]
  [[ "$listed" != *"という言葉"* ]]
}

@test "check.sh lists narration with an intensifier, crowded commas or a named feeling, not dialogue" {
  printf '　途方もなく微細な糸だった。\n　それが、この星系の、最初で最後の返信である。\n　それが、私と妻の、最後の触れ合いになることを、私はまだ知らなかった。\n　私は測りかけの古い節の結び目を置き、アイアの後に続いて、経糸のように伸びる織り道を進んだ。\n　私は激しい自己嫌悪に襲われた。\n「完璧な、歌だ、なあ、おい」\n　彼は頷いた。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/check.sh" story/010.txt story/010.txt
  [ "$status" -eq 0 ]
  intensifier=$(printf '%s\n' "$output" | sed -n '/each intensifier/,/each comma/p')
  [ "$(printf '%s\n' "$intensifier" | grep -cE '^[0-9]+:')" -eq 1 ]
  [[ "$intensifier" == *"1:"*"途方もなく"* ]]
  comma=$(printf '%s\n' "$output" | sed -n '/each comma/,/each named feeling/p')
  [ "$(printf '%s\n' "$comma" | grep -cE '^[0-9]+:')" -eq 2 ]
  [[ "$comma" == *"2:"*"3:"* ]]
  feeling=$(printf '%s\n' "$output" | sed -n '/each named feeling/,/^- /p')
  [ "$(printf '%s\n' "$feeling" | grep -cE '^[0-9]+:')" -eq 1 ]
  [[ "$feeling" == *"5:"*"自己嫌悪"* ]]
  [[ "$output" != *"完璧な、歌だ"* ]]
}

@test "check.sh fails on a missing file" {
  run sh "$BATS_TEST_DIRNAME/check.sh" story/missing.txt story/missing.txt
  [ "$status" -eq 1 ]
}

@test "check.sh fixes the format and lists the lines that break a format rule" {
  printf '彼は頷いた。\n「終わり。」\n「行く」と言った。\n　部屋は3つ……。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/check.sh" story/010.txt story/010.txt
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c '^- ')" -eq 10 ]
  [ "$(head -2 story/010.txt)" = "$(printf '　彼は頷いた。\n「終わり」\n')" ]
  [[ "$output" == *"3:「行く」と言った。"* ]]
  [[ "$output" != *"部屋は3つ"* ]]
  [ "$(sed -n 4p story/010.txt)" = "　部屋は3つ……。" ]
}
