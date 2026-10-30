#!/usr/bin/env bats
# regenerate.sh — only files the generate run wrote are listed; under turbo the run is scoped
# to the changed paths' packages and their dependents; without turbo the repo's generate task
# runs, and a repo with neither is left alone.

bats_require_minimum_version 1.5.0

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/regenerate.sh"
  CALLS="$BATS_TEST_TMPDIR/calls"
  TASKS="$BATS_TEST_TMPDIR/tasks" # what mise tasks ls prints
  : > "$CALLS"
  printf 'lint\ntest\n' > "$TASKS"
  REPO="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$REPO/apps/a/api/src/generated" "$REPO/apps/b/web/src/generated" "$REPO/docs"
  cd "$REPO" || exit
  git init -q
  echo '{"name":"root"}' > package.json
  echo '{"name":"a-api"}' > apps/a/api/package.json
  echo '{"name":"b-web"}' > apps/b/web/package.json
  echo old > apps/a/api/src/generated/routes.ts
  echo old > apps/b/web/src/generated/client.ts
  echo src > apps/a/api/src/controller.ts
  echo doc > docs/readme.md
  git add -A
  git -c user.email=t@t -c user.name=t commit -qm init
  echo noise > apps/b/web/src/generated/client.ts # a generated diff that is not from this run
  # Either generate rewrites a-api's routes.ts and adds schema.ts.
  cat > "$BATS_TEST_TMPDIR/pnpm" <<STUB
#!/usr/bin/env bash
echo "pnpm \$*" >> "$CALLS"
echo new > apps/a/api/src/generated/routes.ts
echo new > apps/a/api/src/generated/schema.ts
STUB
  cat > "$BATS_TEST_TMPDIR/mise" <<STUB
#!/usr/bin/env bash
echo "mise \$*" >> "$CALLS"
if [ "\$1" = tasks ]; then cat "$TASKS"; exit 0; fi
echo new > apps/a/api/src/generated/routes.ts
echo new > apps/a/api/src/generated/schema.ts
STUB
  chmod +x "$BATS_TEST_TMPDIR/pnpm" "$BATS_TEST_TMPDIR/mise"
  PATH="$BATS_TEST_TMPDIR:$PATH"
}

@test "under turbo: lists only the files the run wrote" {
  echo '{}' > turbo.json
  echo changed > apps/a/api/src/controller.ts
  run --separate-stderr "$SCRIPT" apps/a/api/src/controller.ts
  [ "$status" -eq 0 ]
  [ "$output" = "$(printf 'apps/a/api/src/generated/routes.ts\napps/a/api/src/generated/schema.ts')" ]
  [[ "$stderr" == *"generated files listed above"* ]]
  [[ "$stderr" == *"push.sh"* ]]
}

@test "under turbo: filters on each path's package with its dependents and forces the run" {
  echo '{}' > turbo.json
  run --separate-stderr "$SCRIPT" apps/a/api/src/controller.ts apps/b/web
  [ "$status" -eq 0 ]
  grep -q '^pnpm exec turbo run generate --force --filter=...a-api --filter=...b-web$' "$CALLS"
  ! grep -q '^mise run' "$CALLS" || false
}

@test "under turbo: a path outside any package is skipped and nothing runs" {
  echo '{}' > turbo.json
  run --separate-stderr "$SCRIPT" docs/readme.md
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [[ "$stderr" == *"skip (no package): docs/readme.md"* ]]
  [[ "$stderr" == *"Nothing to regenerate"* ]]
  [[ "$stderr" == *"push.sh"* ]]
  ! grep -q '^pnpm' "$CALLS" || false
}

@test "without turbo: runs the generate task and lists what it wrote" {
  printf 'generate  Regenerate\nlint\n' > "$TASKS"
  run --separate-stderr "$SCRIPT" apps/a/api/src/controller.ts
  [ "$status" -eq 0 ]
  [ "$output" = "$(printf 'apps/a/api/src/generated/routes.ts\napps/a/api/src/generated/schema.ts')" ]
  grep -q '^mise run generate$' "$CALLS"
  ! grep -q '^pnpm' "$CALLS" || false
}

@test "without turbo or a generate task it runs nothing and says so" {
  run --separate-stderr "$SCRIPT" apps/a/api/src/controller.ts
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [[ "$stderr" == *"Nothing to regenerate"* ]]
  ! grep -q 'run' "$CALLS" || false
}

@test "fails without arguments" {
  run "$SCRIPT"
  [ "$status" -eq 2 ]
}
