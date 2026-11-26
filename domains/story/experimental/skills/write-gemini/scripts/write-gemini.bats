#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031 # each @test runs in its own subshell, and run sets $output afresh in each
# write.sh — the plot sent to Gemini alone through a stub curl, the reply written to <write's output>.gemini.txt, then the checks over it.

setup() {
  WRITE="$BATS_TEST_DIRNAME/write.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story/plot" "$work/bin"
  cd "$work" || exit
  printf 'プロット本文\n' > story/plot/010-arrival.md
  mkdir -p .agents/refs
  for r in japanese-web-novel-sentence-guard japanese-web-novel-narration-guard; do echo "$r" > ".agents/refs/$r.md"; done
  echo override > .agents/refs/author-override.md
  cat > bin/curl <<'STUB'
#!/bin/sh
cat > request.json
cat response.json
STUB
  chmod +x bin/curl
  PATH="$work/bin:$PATH"
}

reply() {
  jq -n --arg t "$1" '{status: "completed", steps: [{type: "thought"}, {type: "model_output", content: [{type: "text", text: $t}]}]}' > response.json
}

@test "write.sh sends the plot alone and writes the reply beside write's output" {
  reply '　俺は扉を開けた。'
  GEMINI_API_KEY=k run sh "$WRITE" story/plot/010-arrival.md
  [ "$status" -eq 0 ]
  [ "$(cat story/010.gemini.txt)" = '　俺は扉を開けた。' ]
  [ "$(jq -r .input request.json)" = 'プロット本文' ]
  [ "$(jq -r .model request.json)" = gemini-4-neon ]
  [ "$(jq -r 'has("system_instruction")' request.json)" = false ]
  [[ "$output" == *"japanese-web-novel-narration-guard"*"gemini-4-neon wrote story/010.gemini.txt, the output file"* ]]
}

@test "write.sh prints author-rules.md after the guards only when it exists, and sends it nowhere" {
  reply 'x'
  echo mine > author-rules.md
  GEMINI_API_KEY=k run sh "$WRITE" story/plot/010-arrival.md
  [[ "$output" == *narration-guard*override*mine* ]]
  [[ "$(cat request.json)" != *mine* ]]
}

@test "write.sh prints the checks over the reply with its flagged lines, then the hand-off" {
  reply '　彼は知っていたのだ。
　静かな夜だった。冷たい風だった。'
  GEMINI_API_KEY=k run sh "$WRITE" story/plot/010-arrival.md
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c '^Read the whole output file')" -eq 1 ]
  [[ "$output" == *"Hold for the hand-off"*"Cut whole each narration sentence"*"Where the same wording appears twice"*"1:"*"知っていたのだ。"*"2:"*"夜だった。"*"fixed by the loaded rules"* ]]
}

@test "write.sh takes the model from WRITE_GEMINI_MODEL" {
  reply 'x'
  WRITE_GEMINI_MODEL=gemini-4-argon GEMINI_API_KEY=k run sh "$WRITE" story/plot/010-arrival.md
  [ "$(jq -r .model request.json)" = gemini-4-argon ]
}

@test "write.sh names plot.md's output index.gemini.txt" {
  reply 'x'
  printf 'p\n' > story/plot.md
  GEMINI_API_KEY=k run sh "$WRITE" story/plot.md
  [ -f story/index.gemini.txt ]
}

@test "write.sh fails without GEMINI_API_KEY" {
  run env -u GEMINI_API_KEY sh "$WRITE" story/plot/010-arrival.md
  [ "$status" -eq 1 ]
  [[ "$output" == *"GEMINI_API_KEY is not set"* ]]
}

@test "write.sh fails and writes nothing when the call does not complete" {
  echo '{"error": {"message": "model not found"}}' > response.json
  GEMINI_API_KEY=k run sh "$WRITE" story/plot/010-arrival.md
  [ "$status" -eq 1 ]
  [[ "$output" == *"model not found"* ]]
  [ ! -e story/010.gemini.txt ]
}
