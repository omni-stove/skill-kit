#!/usr/bin/env bats
# init.sh — create the missing mise/make files, leave existing ones alone, and list what
# setup must fold in.

setup() {
  INIT="$BATS_TEST_DIRNAME/init.sh"
  repo="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$repo/.agents/refs"
  git init -q "$repo"
  echo rules > "$repo/.agents/refs/mise-rules.md"
  echo story > "$repo/.agents/refs/domain"
  cd "$repo"
}

@test "fails with the sync hint when the kit is not synced" {
  rm .agents/refs/mise-rules.md
  run "$INIT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"skill-kit {game|story|code} sync"* ]]
  echo rules > .agents/refs/mise-rules.md
  rm .agents/refs/domain
  run "$INIT"
  [ "$status" -eq 1 ]
}

@test "fails and asks for git init outside a repository" {
  rm -r .git
  run "$INIT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"git init"* ]]
  [ ! -e Makefile ]
}

@test "creates the forwarding Makefile, mise.toml and .mise/tasks.toml in an empty repo" {
  run "$INIT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"created	Makefile"* ]]
  [[ "$output" == *"created	mise.toml"* ]]
  [[ "$output" == *"created	.mise/tasks.toml"* ]]
  grep -q 'mise run $(TASK)' Makefile
  grep -q '^includes = \[".mise/tasks.toml"\]' mise.toml
  grep -q '^\[setup\]' .mise/tasks.toml
  grep -q '"skill-kit story sync"' .mise/tasks.toml
  grep -q '"skill-kit story update"' .mise/tasks.toml
  grep -q '^\[update\]' .mise/tasks.toml
}

@test "the generated Makefile forwards goals and ARGS to mise run" {
  "$INIT" >/dev/null
  run make -n count src/story ARGS="--limit 10"
  [ "$status" -eq 0 ]
  [[ "$output" == *"mise run count src/story --limit 10"* ]]
  run make -n
  [[ "$output" == *"command -v git"* ]]
  [[ "$output" == *"gh auth status"* ]]
  [[ "$output" == *"mise install"* ]]
  [[ "$output" == *"mise run setup"* ]]
}

@test "keeps existing files and reports a foreign Makefile's targets" {
  printf 'build:\n\tgo build\n\ntest lint:\n\tgo test\n\n.PHONY: build\n' > Makefile
  printf '[tools]\nnode = "22.0.0"\n' > mise.toml
  mkdir .mise && echo '[setup]' > .mise/tasks.toml
  run "$INIT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"foreign	Makefile"* ]]
  [[ "$output" == *"target	build"* ]]
  [[ "$output" == *"target	lint"* ]]
  [[ "$output" == *"target	test"* ]]
  [[ "$output" != *"target	.PHONY"* ]]
  [[ "$output" == *"kept	mise.toml — add"* ]]
  [[ "$output" == *"kept	.mise/tasks.toml"* ]]
  [ "$(head -1 Makefile)" = "build:" ]
  [ "$(cat .mise/tasks.toml)" = "[setup]" ]
}

@test "lists manifests, version pins and package.json scripts" {
  echo 22.1.0 > .node-version
  cat > package.json <<'JSON'
{ "packageManager": "pnpm@10.0.0", "engines": { "node": ">=22" },
  "scripts": { "test": "vitest run", "lint": "biome check ." } }
JSON
  : > pnpm-lock.yaml
  run "$INIT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"manifest	package.json"* ]]
  [[ "$output" == *"manifest	pnpm-lock.yaml"* ]]
  [[ "$output" == *"pin	.node-version	22.1.0"* ]]
  [[ "$output" == *"pin	package.json	pnpm@10.0.0"* ]]
  [[ "$output" == *"script	test	vitest run"* ]]
  [[ "$output" == *"script	lint	biome check ."* ]]
}
