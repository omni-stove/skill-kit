#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031 # each @test runs in its own subshell, and run sets $output afresh in each
# source.sh — deterministic resolution of the source and its output file; draft.sh — the external model's draft, through a stub curl; others.sh — the other files to read, one per number; scene-check.sh — the format fix and the checks before each hand-off.

setup() {
  SOURCE="$BATS_TEST_DIRNAME/source.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story/plot" "$work/sub/plot"
  cd "$work" || exit
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
  [[ "$output" == *'scene-check.sh "story/arrival.txt"'* ]]
}

@test "source.sh says to read and ask when the output exists" {
  : > story/plot/010-co-arrival.md
  : > story/010.txt
  run sh "$SOURCE" story/plot/010-co-arrival.md
  [[ "$output" == *"Read it, ask"* ]]
}

harness_writes() {
  run env -u WRITE_DRAFT_MODEL -u GEMINI_API_KEY "$@" sh "$SOURCE" story/plot/arrival.md
  [[ "$output" == *"Write 1 Scene"* ]]
  [[ "$output" != *"draft.sh"* ]]
}

@test "source.sh hands a new Scene to the harness unless a draft model is set with a key" {
  : > story/plot/arrival.md
  harness_writes
  harness_writes WRITE_DRAFT_MODEL=m
  harness_writes GEMINI_API_KEY=k
  harness_writes WRITE_DRAFT_MODEL= GEMINI_API_KEY=k
}

@test "source.sh hands a new Scene to draft.sh when a draft model is set with a key" {
  : > story/plot/arrival.md
  WRITE_DRAFT_MODEL=m GEMINI_API_KEY=k run sh "$SOURCE" story/plot/arrival.md
  [[ "$output" == *'draft.sh "story/plot/arrival.md" "story/arrival.txt"'* ]]
  [[ "$output" != *"Write 1 Scene"* ]]
}

@test "source.sh revises a .txt in the harness even with a draft model set" {
  : > story/010.txt
  WRITE_DRAFT_MODEL=m GEMINI_API_KEY=k run sh "$SOURCE" story/010.txt
  [[ "$output" == *"revise it"* ]]
  [[ "$output" != *"draft.sh"* ]]
}

stub_curl() {
  mkdir -p bin .agents/refs
  for r in format style rhythm; do echo "rule-$r" > ".agents/refs/japanese-web-novel-$r.md"; done
  printf '%s' "$1" > response.json
  cat > bin/curl <<'STUB'
#!/bin/sh
cat > request.json
cat response.json
STUB
  chmod +x bin/curl
  PATH="$work/bin:$PATH"
  printf 'プロット本文\n' > story/plot/arrival.md
  printf 'レポート本文\n' > report.txt
}

@test "draft.sh sends the rules, plot, report and output so far, and appends the Scene after a *" {
  stub_curl '{"status":"completed","steps":[{"type":"thought"},{"type":"model_output","content":[{"type":"text","text":"　彼は扉を開けた。"}]}]}'
  printf '　前の場面。\n' > story/arrival.txt
  WRITE_DRAFT_MODEL=gemini-4-argon GEMINI_API_KEY=k run sh "$BATS_TEST_DIRNAME/draft.sh" story/plot/arrival.md story/arrival.txt report.txt
  [ "$status" -eq 0 ]
  [[ "$output" == *'scene-check.sh "story/arrival.txt"'* ]]
  [ "$(cat story/arrival.txt)" = "$(printf '　前の場面。\n*\n　彼は扉を開けた。')" ]
  [ "$(jq -r .model request.json)" = gemini-4-argon ]
  [ "$(jq -r .generation_config.thinking_level request.json)" = high ]
  [[ "$(jq -r .system_instruction request.json)" == *rule-rhythm* ]]
  [[ "$(jq -r .input request.json)" == *プロット本文*レポート本文*前の場面。* ]]
}

@test "draft.sh sends a story past the exec argument limit" {
  stub_curl '{"status":"completed","steps":[{"type":"model_output","content":[{"type":"text","text":"　続き。"}]}]}'
  awk 'BEGIN { for (i = 0; i < 20000; i++) print "　長い長い物語の一行。" }' > story/arrival.txt
  WRITE_DRAFT_MODEL=gemini-4-argon GEMINI_API_KEY=k run sh "$BATS_TEST_DIRNAME/draft.sh" story/plot/arrival.md story/arrival.txt report.txt
  [ "$status" -eq 0 ]
  [ "$(tail -1 story/arrival.txt)" = "　続き。" ]
  [ "$(jq -r .input request.json | grep -c 長い長い物語)" -eq 20000 ]
}

@test "draft.sh writes the first Scene without a *" {
  stub_curl '{"status":"completed","steps":[{"type":"model_output","content":[{"type":"text","text":"　始まり。"}]}]}'
  WRITE_DRAFT_MODEL=gemini-4-argon GEMINI_API_KEY=k run sh "$BATS_TEST_DIRNAME/draft.sh" story/plot/arrival.md story/arrival.txt report.txt
  [ "$status" -eq 0 ]
  [ "$(cat story/arrival.txt)" = "　始まり。" ]
}

@test "draft.sh hands the Scene back to the harness when the API fails or the model or key is missing" {
  stub_curl '{"error":{"code":404,"message":"not found"}}'
  WRITE_DRAFT_MODEL=gemini-4-argon GEMINI_API_KEY=k run sh "$BATS_TEST_DIRNAME/draft.sh" story/plot/arrival.md story/arrival.txt report.txt
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]
  [[ "$output" == *"Write 1 Scene"* ]]
  [ ! -e story/arrival.txt ]
  [[ "$output" == *"gemini-4-argon did not write"* ]]
  WRITE_DRAFT_MODEL=m run env -u GEMINI_API_KEY sh "$BATS_TEST_DIRNAME/draft.sh" story/plot/arrival.md story/arrival.txt report.txt
  [ "$status" -eq 1 ]
  [[ "$output" == *"GEMINI_API_KEY is not set"* ]]
  run env -u WRITE_DRAFT_MODEL GEMINI_API_KEY=k sh "$BATS_TEST_DIRNAME/draft.sh" story/plot/arrival.md story/arrival.txt report.txt
  [ "$status" -eq 1 ]
  [[ "$output" == *"WRITE_DRAFT_MODEL is not set"* ]]
}

@test "source.sh fails on a missing source" {
  run sh "$SOURCE" story/plot/missing.md
  [ "$status" -eq 1 ]
}

@test "scene-check.sh prints the five whole-file checks" {
  printf '　彼は頷いた。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/scene-check.sh" story/010.txt
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c '^- ')" -eq 5 ]
  [[ "$output" == *"[Scene name] complete."* ]]
}

@test "scene-check.sh lists narration sentences ending on the copula, not dialogue" {
  printf '　彼は頷いた。覚悟を決めた目だった。\n「嘘だった」\n　静かな夜だった。\n　鍵は古い真鍮のようだった。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/scene-check.sh" story/010.txt
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c '^- ')" -eq 6 ]
  [[ "$output" == *"1:"*"目だった。"* ]]
  [[ "$output" == *"3:"*"夜だった。"* ]]
  [[ "$output" == *"4:"*"ようだった。"* ]]
  [[ "$output" != *"嘘だった"* ]]
}

@test "scene-check.sh lists negative narration sentences, not dialogue or thoughts" {
  printf '　返事はなかった。\n「知らない。帰れ」\n　廊下には誰もいない。\n『来ない。』\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/scene-check.sh" story/010.txt
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c '^- ')" -eq 6 ]
  [[ "$output" == *"1:"*"返事はなかった。"* ]]
  [[ "$output" == *"3:"*"誰もいない。"* ]]
  [[ "$output" != *"知らない"* ]]
  [[ "$output" != *"来ない"* ]]
}

@test "scene-check.sh fails on a missing file" {
  run sh "$BATS_TEST_DIRNAME/scene-check.sh" story/missing.txt
  [ "$status" -eq 1 ]
}

@test "scene-check.sh fixes the format and lists the lines that break a format rule" {
  printf '彼は頷いた。\n「終わり。」\n　部屋は3つ。\n' > story/010.txt
  run sh "$BATS_TEST_DIRNAME/scene-check.sh" story/010.txt
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c '^- ')" -eq 6 ]
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
