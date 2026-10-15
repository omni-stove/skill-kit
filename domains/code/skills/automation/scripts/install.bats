#!/usr/bin/env bats
# install.sh — copy workflow templates, keep existing ones, report missing tasks and the
# settings the user must do.

setup() {
  INSTALL="$BATS_TEST_DIRNAME/install.sh"
  repo="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$repo/.agents/refs/workflows" "$repo/.mise" "$repo/bin"
  echo 'name: CI' > "$repo/.agents/refs/workflows/ci.yml"
  echo 'name: PR Review' > "$repo/.agents/refs/workflows/pr-review.yml"
  printf '[install]\nrun = ":"\n[lint]\nrun = "x"\n' > "$repo/.mise/tasks.toml"
  printf '#!/bin/sh\nexit 1\n' > "$repo/bin/gh"
  chmod +x "$repo/bin/gh"
  PATH="$repo/bin:$PATH"
  cd "$repo"
}

@test "fails with the sync hint when the templates are not synced" {
  rm -r .agents/refs/workflows
  run "$INSTALL"
  [ "$status" -eq 1 ]
  [[ "$output" == *"skill-kit code sync"* ]]
}

@test "fails when the repo has no mise tasks yet" {
  rm .mise/tasks.toml
  run "$INSTALL"
  [ "$status" -eq 1 ]
  [[ "$output" == *"init skill"* ]]
}

@test "copies templates, keeps existing files, reports missing tasks and todos" {
  mkdir -p .github/workflows
  echo mine > .github/workflows/ci.yml
  run "$INSTALL"
  [ "$status" -eq 0 ]
  [[ "$output" == *"kept	.github/workflows/ci.yml"* ]]
  [[ "$output" == *"created	.github/workflows/pr-review.yml"* ]]
  [ "$(cat .github/workflows/ci.yml)" = "mine" ]
  [ "$(cat .github/workflows/pr-review.yml)" = "name: PR Review" ]
  [[ "$output" == *"missing	task test"* ]]
  [[ "$output" != *"missing	task lint"* ]]
  [[ "$output" == *"todo	gh auth login"* ]]
  [[ "$output" == *"todo	gh secret set ANTHROPIC_API_KEY"* ]]
}
