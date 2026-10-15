#!/usr/bin/env bats
# commit-push.sh with git, make and gh stubs: lint + test before the commit, one commit, push.

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/commit-push.sh"
  KIT="$(cd "$BATS_TEST_DIRNAME/../../../../.." && pwd)"
  repo="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$repo/.agents/refs" "$repo/bin"
  ln -s "$KIT/shared/refs/push-with-merge.sh" "$repo/.agents/refs/push-with-merge.sh"
  CALLS="$BATS_TEST_TMPDIR/calls"
  : > "$CALLS"
  cat > "$repo/bin/git" <<STUB
#!/usr/bin/env bash
echo "git \$*" >> "$CALLS"
[ "\$1" = rev-parse ] && exit 1
exit 0
STUB
  cat > "$repo/bin/make" <<STUB
#!/usr/bin/env bash
echo "make \$*" >> "$CALLS"
[ "\$1" = "\${MAKE_FAIL:-}" ] && exit 1
exit 0
STUB
  printf '#!/usr/bin/env bash\necho 5\n' > "$repo/bin/gh"
  chmod +x "$repo/bin/git" "$repo/bin/make" "$repo/bin/gh"
  PATH="$repo/bin:$PATH"
  cd "$repo"
}

@test "lints and tests, then commits the files and pushes" {
  run "$SCRIPT" a.ts b.ts
  [ "$status" -eq 0 ]
  [ "$(grep -n '^make test$' "$CALLS" | cut -d: -f1)" -lt "$(grep -n '^git add' "$CALLS" | cut -d: -f1)" ]
  grep -q '^git add a.ts b.ts$' "$CALLS"
  grep -q '^git push$' "$CALLS"
  [[ "$output" == *"watch.sh 5"* ]]
}

@test "stops when lint fails, and needs at least one file" {
  MAKE_FAIL=lint run "$SCRIPT" a.ts
  [ "$status" -eq 1 ]
  ! grep -q '^git' "$CALLS"
  run "$SCRIPT"
  [ "$status" -eq 2 ]
}
