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
  cd "$repo" || exit
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

@test "initializes a git repository when there is none" {
  rm -r .git
  run "$INIT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"created	.git"* ]]
  git rev-parse --is-inside-work-tree
  [ -e Makefile ]
}

@test "leaves an existing git repository alone" {
  run "$INIT"
  [ "$status" -eq 0 ]
  [[ "$output" != *"created	.git"* ]]
}

@test "creates the forwarding Makefile, mise.toml and .mise/tasks.toml in an empty repo" {
  run "$INIT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"created	Makefile"* ]]
  [[ "$output" == *"created	mise.toml"* ]]
  [[ "$output" == *"created	.mise/tasks.toml"* ]]
  grep -q 'mise run $(TASK)' Makefile
  grep -q '^includes = \[".mise/tasks.toml"\]' mise.toml
  grep -q '^\[install\]' .mise/tasks.toml
  grep -q '^run = ":"' .mise/tasks.toml
  grep -q '^\[setup\]' .mise/tasks.toml
  grep -q '^depends = \["install"\]' .mise/tasks.toml
  [[ "$output" == *"install	:"* ]]
  grep -qF '"curl -fsSL https://raw.githubusercontent.com/omni-stove/skill-kit/main/install.sh | sh"' .mise/tasks.toml
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
  [[ "$output" != *"gh auth"* ]]
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
  [[ "$output" == *"updated	mise.toml — added [task_config] includes"* ]]
  grep -q '^includes = \[".mise/tasks.toml"\]' mise.toml
  [[ "$output" == *"updated	.mise/tasks.toml — added tasks: install update"* ]]
  [[ "$output" == *"todo	.mise/tasks.toml — give [setup] depends"* ]]
  [ "$(head -1 Makefile)" = "build:" ]
  [ "$(head -1 .mise/tasks.toml)" = "[setup]" ]
  grep -q '^\[install\]' .mise/tasks.toml
  grep -q '^\[update\]' .mise/tasks.toml
  [ "$(grep -c '^\[setup\]' .mise/tasks.toml)" -eq 1 ]
}

@test "a second run on an initialized repo keeps everything" {
  "$INIT" >/dev/null
  run "$INIT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Then run make setup, then mise tasks."* ]]
  [[ "$output" != *"warning"* ]]
  [[ "$output" == *"kept	Makefile"* ]]
  [[ "$output" == *"kept	mise.toml"* ]]
  [[ "$output" == *"kept	.mise/tasks.toml"* ]]
  [[ "$output" != *"updated"* ]]
  [[ "$output" != *"todo"* ]]
}

@test "brings an older forwarding Makefile up to the template and shows the diff" {
  "$INIT" >/dev/null
  sed -i '' '/mise trust -q/d' Makefile
  run "$INIT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"updated	Makefile"* ]]
  [[ "$output" == *"+	@mise trust -q"* ]]
  grep -q 'mise trust -q' Makefile
}

@test "leaves a mise.toml that already has a task_config section to the user" {
  printf '[task_config]\nincludes = ["other.toml"]\n' > mise.toml
  run "$INIT"
  [[ "$output" == *"kept	mise.toml — add"* ]]
  [ "$(grep -c task_config mise.toml)" -eq 1 ]
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
  [[ "$output" == *"install	pnpm install --frozen-lockfile"* ]]
  grep -q '^run = "pnpm install --frozen-lockfile"' .mise/tasks.toml
  [[ "$output" == *"tool	node = \"22\""* ]]
  [[ "$output" == *"tool	pnpm = \"10\""* ]]
  [ "$(grep -c 'tool	node' <<< "$output")" -eq 1 ]
  [[ "$output" == *"added	task test — pnpm run test"* ]]
  [[ "$output" == *"added	task lint — pnpm run lint"* ]]
  grep -q '^\[test\]' .mise/tasks.toml
  grep -q '^description = "vitest run"' .mise/tasks.toml
  grep -q '^run = "pnpm run lint"' .mise/tasks.toml
  run "$INIT"
  [[ "$output" != *"added	task"* ]]
  [ "$(grep -c '^\[test\]' .mise/tasks.toml)" -eq 1 ]
}

@test "escapes quotes in a script body, and leaves an unnameable script to the user" {
  cat > package.json <<'JSON'
{ "scripts": { "say": "echo \"hi\"", "Build:Web": "x" } }
JSON
  run "$INIT"
  grep -q '^description = "echo \\"hi\\""' .mise/tasks.toml
  grep -q '^run = "npm run say"' .mise/tasks.toml
  [[ "$output" == *"todo	script Build:Web"* ]]
  ! grep -q 'Build:Web' .mise/tasks.toml || false
}

@test "lists tool lines from .tool-versions and a go pin" {
  printf 'terraform 1.9.2\nnodejs 20.1.0\n' > .tool-versions
  echo 1.22.3 > .go-version
  run "$INIT"
  [[ "$output" == *"tool	terraform = \"1\""* ]]
  [[ "$output" == *"tool	nodejs = \"20\""* ]]
  [[ "$output" == *"tool	go = \"1\""* ]]
}

@test "flags a setup task that still installs the kit through gh api" {
  mkdir .mise && printf '[setup]\ndepends = ["install"]\nrun = [\n  "gh api repos/omni-stove/skill-kit/contents/install.sh -q .content | base64 -d | sh",\n]\n' > .mise/tasks.toml
  run "$INIT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"todo	.mise/tasks.toml — in [setup], replace the gh api install line"* ]]
}

@test "flags an install task that disagrees with the manifest" {
  : > go.mod
  mkdir .mise && printf '[install]\nrun = "make deps"\n' > .mise/tasks.toml
  run "$INIT"
  [[ "$output" == *'todo	.mise/tasks.toml — [install] runs "make deps"; the manifest calls for "go mod download"'* ]]
  grep -q '^run = "make deps"' .mise/tasks.toml
}

@test "says to delete a foreign Makefile once every target is a task" {
  printf 'build:\n\tgo build\n' > Makefile
  mkdir .mise && printf '[build]\nrun = "go build"\n' > .mise/tasks.toml
  run "$INIT"
  [[ "$output" == *"foreign	Makefile — every target is a task now"* ]]
  [[ "$output" != *"target	build"* ]]
}

@test "picks the install command from the lockfile present" {
  : > go.mod
  run "$INIT"
  [[ "$output" == *"install	go mod download"* ]]
}

@test "appends the code rules to AGENTS.md once when the code domain is synced" {
  printf '# Code rules\n\nrule\n' > .agents/refs/code-rules.md
  echo existing > AGENTS.md
  run "$INIT"
  [[ "$output" == *"appended	AGENTS.md"* ]]
  [ "$(head -1 AGENTS.md)" = "existing" ]
  grep -qx '# Code rules' AGENTS.md
  run "$INIT"
  [[ "$output" == *"kept	AGENTS.md"* ]]
  [ "$(grep -c '# Code rules' AGENTS.md)" -eq 1 ]
}

@test "replaces the code rules block when the rules changed, keeping the rest of AGENTS.md" {
  printf 'intro\n\n# Code rules\n\nold rule\n\n# Other\n\nkeep me\n' > AGENTS.md
  printf '# Code rules\n\nnew rule\nsecond line\n' > .agents/refs/code-rules.md
  run "$INIT"
  [[ "$output" == *"updated	AGENTS.md"* ]]
  [ "$(cat AGENTS.md)" = "$(printf 'intro\n\n# Code rules\n\nnew rule\nsecond line\n\n# Other\n\nkeep me')" ]
  run "$INIT"
  [[ "$output" == *"kept	AGENTS.md"* ]]
}

@test "replaces a changed code rules block at the end of AGENTS.md" {
  printf 'intro\n\n# Code rules\n\nold rule\n' > AGENTS.md
  printf '# Code rules\n\nnew rule\n' > .agents/refs/code-rules.md
  run "$INIT"
  [[ "$output" == *"updated	AGENTS.md"* ]]
  [ "$(cat AGENTS.md)" = "$(printf 'intro\n\n# Code rules\n\nnew rule')" ]
}

@test "leaves AGENTS.md alone in a domain without code rules" {
  echo existing > AGENTS.md
  run "$INIT"
  [ "$(cat AGENTS.md)" = "existing" ]
  [[ "$output" != *"AGENTS.md"* ]]
}

@test "creates .claude/settings.json registering the hook, and keeps it after" {
  mkdir -p .claude/hooks && : > .claude/hooks/llm-instruction-rules.sh
  run "$INIT"
  [[ "$output" == *"created	.claude/settings.json"* ]]
  [ "$(jq -r '.hooks.PreToolUse[0].matcher' .claude/settings.json)" = "Write|Edit" ]
  [ "$(jq -r '.hooks.PreToolUse[0].hooks[0].command' .claude/settings.json)" = '"$CLAUDE_PROJECT_DIR/.claude/hooks/llm-instruction-rules.sh"' ]
  run "$INIT"
  [[ "$output" == *"kept	.claude/settings.json"* ]]
}

@test "adds the hook to an existing settings.json without touching the rest" {
  mkdir -p .claude/hooks && : > .claude/hooks/llm-instruction-rules.sh
  echo '{"permissions":{"allow":["Bash(ls)"]},"hooks":{"PreToolUse":[{"matcher":"Read","hooks":[]}]}}' > .claude/settings.json
  run "$INIT"
  [[ "$output" == *"updated	.claude/settings.json"* ]]
  [ "$(jq -r '.permissions.allow[0]' .claude/settings.json)" = "Bash(ls)" ]
  [ "$(jq -r '.hooks.PreToolUse | length' .claude/settings.json)" -eq 2 ]
  [ "$(jq -r '.hooks.PreToolUse[0].matcher' .claude/settings.json)" = "Read" ]
  [[ "$(jq -r '.hooks.PreToolUse[1].hooks[0].command' .claude/settings.json)" == *llm-instruction-rules.sh* ]]
}

@test "prints the entry to add when settings.json cannot be merged" {
  mkdir -p .claude/hooks && : > .claude/hooks/llm-instruction-rules.sh
  echo 'not json' > .claude/settings.json
  run "$INIT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"todo	.claude/settings.json"* ]]
  [[ "$output" == *'"matcher": "Write|Edit"'* ]]
  [ "$(cat .claude/settings.json)" = "not json" ]
}

@test "leaves settings.json alone when the hook is not deployed" {
  run "$INIT"
  [ ! -e .claude/settings.json ]
}

@test "warns about a symlinked or ignored kit file" {
  "$INIT" >/dev/null
  rm mise.toml && ln -s /dev/null mise.toml
  echo Makefile > .gitignore
  run "$INIT"
  [[ "$output" == *"warning	mise.toml is a symlink"* ]]
  [[ "$output" == *"warning	Makefile is ignored by git"* ]]
}
