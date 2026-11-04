#!/usr/bin/env bats
# names.sh — the repo's lines per name, outside the synced kit, capped, and the next step.

bats_require_minimum_version 1.5.0

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/names.sh"
  cd "$BATS_TEST_TMPDIR" || return
  git init -q .
  mkdir -p characters/main .agents/refs .claude
  echo '# 佐藤ハルカ' > characters/main/haruka.md
  git add characters
  echo 'ハルカの妹' > notes.md                # untracked, still searched
  echo 'ハルカ' > .agents/refs/x.md
  echo 'ハルカ' > .claude/x.md
}

@test "lists hits in tracked and untracked files, skipping .agents and .claude" {
  run --separate-stderr "$SCRIPT" ハルカ
  [ "$status" -eq 0 ]
  [[ "$output" == *"==> ハルカ: 2"* ]]
  [[ "$output" == *"characters/main/haruka.md:1:# 佐藤ハルカ"* ]]
  [[ "$output" == *"notes.md:1:ハルカの妹"* ]]
  [[ "$output" != *".agents"* ]]
  [[ "$output" != *".claude"* ]]
  [[ "$stderr" == *"Count a hit above as a collision"* ]]
}

@test "a name with no hits says none" {
  run --separate-stderr "$SCRIPT" ミナト ハルカ
  [ "$status" -eq 0 ]
  [[ "$output" == *"==> ミナト: none"* ]]
  [[ "$output" == *"==> ハルカ: 2"* ]]
}

@test "caps the lines per name and counts the rest" {
  for i in $(seq 25); do echo "ユウ $i" >> many.md; done
  run --separate-stderr "$SCRIPT" ユウ
  [[ "$output" == *"==> ユウ: 25"* ]]
  [[ "$output" == *"... 5 more"* ]]
  [ "$(printf '%s\n' "$output" | grep -c '^many.md:')" -eq 20 ]
}

@test "no name is a usage error" {
  run --separate-stderr "$SCRIPT"
  [ "$status" -eq 2 ]
  [[ "$stderr" == *"usage: names.sh"* ]]
}

@test "outside a git repo says where to run it" {
  cd "$(mktemp -d)" || return
  run --separate-stderr "$SCRIPT" ハルカ
  [ "$status" -eq 2 ]
  [[ "$stderr" == *"story repo's root"* ]]
}
