#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031 # each @test runs in its own subshell, and run sets $output afresh in each
# source.sh — deterministic resolution of the source and its output file; scene.sh — the writing step, held until the report is saved; others.sh — the other files to read, one per number; scene-check.sh — the format fix and the checks before each hand-off; check.sh — the external model's findings over the finished file, through a stub curl.

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
}

@test "source.sh says to start fresh when the output is missing" {
  : > story/plot/arrival.md
  run sh "$SOURCE" story/plot/arrival.md
  [[ "$output" == *"does not exist yet"* ]]
  [[ "$output" == *'others.sh "story/plot/arrival.md"'* ]]
  [[ "$output" == *'scene.sh "story/plot/arrival.md" "story/arrival.txt" <the report file>'* ]]
  [[ "$output" != *"Write 1 Scene"* ]]
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
  [[ "$output" != *"does not exist yet"* ]]
}

@test "source.sh says to read and ask when the output exists" {
  : > story/plot/010-co-arrival.md
  : > story/010.txt
  run sh "$SOURCE" story/plot/010-co-arrival.md
  [[ "$output" == *"Read it, ask"* ]]
}

stub_curl() {
  mkdir -p bin .agents/refs
  echo "rule-style" > .agents/refs/japanese-web-novel-style.md
  printf '%s' "$1" > response.json
  cat > bin/curl <<'STUB'
#!/bin/sh
cat > request.json
cat response.json
STUB
  chmod +x bin/curl
  PATH="$work/bin:$PATH"
  mkdir -p characters
  printf '湊は左利き。\n' > characters/minato.md
  printf 'プロット本文\n## 参照\n- @characters/minato.md\n' > story/plot/arrival.md
  printf 'レポート本文\n' > report.txt
  printf '　俺は扉を開けた。\n　右手でペンを取った。\n' > story/arrival.txt
}

reply() {
  jq -n --arg t "$1" '{status: "completed", steps: [{type: "thought"}, {type: "model_output", content: [{type: "text", text: $t}]}]}'
}

@test "check.sh sends the numbered Scene, the style rules and the cited files" {
  stub_curl "$(reply '{"findings": []}')"
  WRITE_CHECK_MODEL=gemini-4-argon GEMINI_API_KEY=k run sh "$BATS_TEST_DIRNAME/check.sh" story/plot/arrival.md story/arrival.txt report.txt
  [ "$status" -eq 0 ]
  [ "$(jq -r .model request.json)" = gemini-4-argon ]
  [ "$(jq -r .generation_config.thinking_level request.json)" = high ]
  [ "$(jq -r .response_format.mime_type request.json)" = application/json ]
  [ "$(jq -r '.response_format.schema.properties.findings.type' request.json)" = array ]
  [[ "$(jq -r .system_instruction request.json)" == *rule-style* ]]
  in=$(jq -r .input request.json)
  [[ "$in" == *"2	　右手でペンを取った。"* ]]
  [[ "$in" == *"=== story/plot/arrival.md"*プロット本文*"=== report.txt"*レポート本文*"=== README.md"*港町*"=== characters/minato.md"*左利き* ]]
}

@test "check.sh keeps only findings with a matching line, rule, basis and quote" {
  stub_curl "$(reply '{"findings": [
 {"line": 2, "text": "右手で", "kind": "contradiction", "rule": "設定", "basis": "湊は左利き", "file": "characters/minato.md", "quote": "湊は左利き。"},
 {"line": 2, "text": "右手で", "kind": "contradiction", "rule": "設定", "basis": "引用なし"},
 {"line": 2, "text": "右手で", "kind": "contradiction", "rule": "設定", "basis": "捏造の引用", "file": "characters/minato.md", "quote": "湊は右利き。"},
 {"line": 1, "text": "右手で", "kind": "repetition", "rule": "重複", "basis": "行が違う"},
 {"line": 9, "text": "扉", "kind": "repetition", "rule": "重複", "basis": "範囲外"},
 {"line": 1, "text": "扉", "kind": "ending", "rule": "", "basis": "ルールなし"},
 {"line": 1, "text": "扉を開けた", "kind": "continuity", "rule": "位置", "basis": "前の行と食い違う"}
]}')"
  WRITE_CHECK_MODEL=gemini-4-argon GEMINI_API_KEY=k run sh "$BATS_TEST_DIRNAME/check.sh" story/plot/arrival.md story/arrival.txt report.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *"1: 扉を開けた [位置] 前の行と食い違う"*"2: 右手で [設定] 湊は左利き — characters/minato.md:「湊は左利き。」"* ]]
  [[ "$output" != *引用なし* ]]
  [[ "$output" != *捏造の引用* ]]
  [[ "$output" != *行が違う* ]]
  [[ "$output" != *範囲外* ]]
  [[ "$output" != *ルールなし* ]]
  [[ "$output" != *"Where the same wording appears twice"* ]]
  [[ "$output" == *"[Output file] complete."* ]]
}

@test "check.sh runs the checks in the harness when the model fails or is not set" {
  stub_curl '{"error":{"code":404,"message":"not found"}}'
  printf '　静かな夜だった。\n' > story/arrival.txt
  WRITE_CHECK_MODEL=gemini-4-argon GEMINI_API_KEY=k run sh "$BATS_TEST_DIRNAME/check.sh" story/plot/arrival.md story/arrival.txt report.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *"gemini-4-argon failed"*"not found"* ]]
  [[ "$output" == *"Where the same wording appears twice"*"1:　静かな夜だった。"* ]]
  stub_curl "$(reply 'no list here')"
  WRITE_CHECK_MODEL=gemini-4-argon GEMINI_API_KEY=k run sh "$BATS_TEST_DIRNAME/check.sh" story/plot/arrival.md story/arrival.txt
  [[ "$output" == *"no findings list"* ]]
  run env -u WRITE_CHECK_MODEL GEMINI_API_KEY=k sh "$BATS_TEST_DIRNAME/check.sh" story/plot/arrival.md story/arrival.txt
  [ "$status" -eq 0 ]
  [[ "$output" != *"failed"* ]]
  [[ "$output" == *"Where the same wording appears twice"* ]]
}

@test "source.sh fails on a missing source" {
  run sh "$SOURCE" story/plot/missing.md
  [ "$status" -eq 1 ]
}

@test "scene-check.sh prints the four whole-file checks and hands the finished file to check.sh" {
  printf '　彼は頷いた。\n' > story/010.txt
  : > story/plot/arrival.md
  run sh "$BATS_TEST_DIRNAME/scene-check.sh" story/plot/arrival.md story/010.txt report.txt
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c '^- ')" -eq 4 ]
  [[ "$output" == *"[Scene name] complete."* ]]
  [[ "$output" == *'check.sh "story/plot/arrival.md" "story/010.txt" "report.txt" instead'* ]]
  run sh "$BATS_TEST_DIRNAME/scene-check.sh" story/010.txt story/010.txt
  [[ "$output" == *'check.sh "story/010.txt" "story/010.txt" instead'* ]]
}

@test "check.sh lists narration sentences ending on the copula, not dialogue, when the model is not set" {
  printf '　彼は頷いた。覚悟を決めた目だった。\n「嘘だった」\n　静かな夜だった。\n　鍵は古い真鍮のようだった。\n' > story/010.txt
  run env -u WRITE_CHECK_MODEL sh "$BATS_TEST_DIRNAME/check.sh" story/010.txt story/010.txt
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c '^- ')" -eq 2 ]
  [[ "$output" == *"1:"*"目だった。"* ]]
  [[ "$output" == *"3:"*"夜だった。"* ]]
  [[ "$output" == *"4:"*"ようだった。"* ]]
  [[ "$output" != *"嘘だった"* ]]
}

@test "scene-check.sh lists negative narration sentences, not dialogue or thoughts" {
  printf '　返事はなかった。\n「知らない。帰れ」\n　廊下には誰もいない。\n『来ない。』\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/scene-check.sh" story/010.txt story/010.txt
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c '^- ')" -eq 5 ]
  [[ "$output" == *"1:"*"返事はなかった。"* ]]
  [[ "$output" == *"3:"*"誰もいない。"* ]]
  [[ "$output" != *"知らない"* ]]
  [[ "$output" != *"来ない"* ]]
}

@test "scene-check.sh and check.sh fail on a missing file" {
  run sh "$BATS_TEST_DIRNAME/scene-check.sh" story/missing.txt story/missing.txt
  [ "$status" -eq 1 ]
  run sh "$BATS_TEST_DIRNAME/check.sh" story/missing.txt story/missing.txt
  [ "$status" -eq 1 ]
}

@test "scene-check.sh fixes the format and lists the lines that break a format rule" {
  printf '彼は頷いた。\n「終わり。」\n　部屋は3つ。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/scene-check.sh" story/010.txt story/010.txt
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c '^- ')" -eq 5 ]
  [ "$(head -2 story/010.txt)" = "$(printf '　彼は頷いた。\n「終わり」\n')" ]
  [[ "$output" == *"3:　部屋は3つ。"* ]]
}

@test "others.sh prints the story file where a number has both, else the plot file" {
  : > story/plot/010-co-arrival.md
  : > story/010.txt
  : > story/plot/020-night.md
  : > story/plot/030-dawn.md
  : > story/plot/040-end.md
  run sh "$BATS_TEST_DIRNAME/others.sh" story/plot/030-dawn.md
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "story/010.txt" ]
  [ "${lines[1]}" = "story/plot/020-night.md" ]
  [ "${lines[2]}" = "story/plot/040-end.md" ]
  [ "${#lines[@]}" -eq 3 ]
}

@test "others.sh leaves out the source's own pair" {
  : > story/plot/010-co-arrival.md
  : > story/010.txt
  : > story/plot/020-night.md
  : > story/020.txt
  run sh "$BATS_TEST_DIRNAME/others.sh" story/plot/020-night.md
  [ "$output" = "story/010.txt" ]
  run sh "$BATS_TEST_DIRNAME/others.sh" story/020.txt
  [ "$output" = "story/010.txt" ]
}

@test "others.sh fails on a missing source" {
  run sh "$BATS_TEST_DIRNAME/others.sh" story/plot/missing.md
  [ "$status" -eq 1 ]
}
