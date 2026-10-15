#!/usr/bin/env bats
# regenerate.sh — only files the generate task wrote are listed; a repo without the task is
# left alone.

bats_require_minimum_version 1.5.0

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/regenerate.sh"
  CALLS="$BATS_TEST_TMPDIR/calls"
  TASKS="$BATS_TEST_TMPDIR/tasks" # what mise tasks ls prints
  : > "$CALLS"
  printf 'generate  Regenerate\nlint\n' > "$TASKS"
  REPO="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$REPO/src/generated" "$REPO/docs"
  cd "$REPO"
  git init -q
  echo old > src/generated/routes.ts
  echo old > src/generated/client.ts
  echo src > src/main.ts
  git add -A
  git -c user.email=t@t -c user.name=t commit -qm init
  echo noise > src/generated/client.ts # a generated diff that is not from this run
  # The generate task rewrites routes.ts and adds schema.ts.
  cat > "$BATS_TEST_TMPDIR/mise" <<STUB
#!/usr/bin/env bash
echo "mise \$*" >> "$CALLS"
if [ "\$1" = tasks ]; then cat "$TASKS"; exit 0; fi
echo new > src/generated/routes.ts
echo new > src/generated/schema.ts
STUB
  chmod +x "$BATS_TEST_TMPDIR/mise"
  PATH="$BATS_TEST_TMPDIR:$PATH"
}

@test "lists only the files the generate task wrote" {
  echo changed > src/main.ts
  run --separate-stderr "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "$(printf 'src/generated/routes.ts\nsrc/generated/schema.ts')" ]
  [[ "$stderr" == *"generated files listed above"* ]]
  [[ "$stderr" == *"push.sh"* ]]
  grep -q 'mise run generate' "$CALLS"
}

@test "without a generate task it runs nothing and says so" {
  printf 'lint\ntest\n' > "$TASKS"
  run --separate-stderr "$SCRIPT"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [[ "$stderr" == *"no generate task"* ]]
  [[ "$stderr" == *"push.sh"* ]]
  ! grep -q 'mise run' "$CALLS"
}

@test "rejects arguments" {
  run "$SCRIPT" src
  [ "$status" -eq 2 ]
}
