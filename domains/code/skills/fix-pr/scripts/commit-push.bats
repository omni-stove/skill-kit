#!/usr/bin/env bats
# commit-push.sh with git and make stubs: lint + test, add + commit + push, the empty commit
# with no files, the retry through push-with-merge when the remote is ahead, and finishing an
# in-progress merge.

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/commit-push.sh"
  KIT="$(cd "$BATS_TEST_DIRNAME/../../../../.." && pwd)"
  repo="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$repo/.agents/refs" "$repo/bin"
  ln -s "$KIT/shared/refs/push-with-merge.sh" "$repo/.agents/refs/push-with-merge.sh"
  CALLS="$BATS_TEST_TMPDIR/calls"
  : > "$CALLS"
  echo 0 > "$BATS_TEST_TMPDIR/pushes"
  cat > "$repo/bin/git" <<STUB
#!/usr/bin/env bash
echo "git \$*" >> "$CALLS"
if [ "\$1" = "rev-parse" ]; then
  case "\$*" in
    *MERGE_HEAD*) [ "\${GIT_MERGE_IN_PROGRESS:-0}" = 1 ] && { echo deadbeef; exit 0; }; exit 1 ;;
    *HEAD^2*) exit 1 ;;
  esac
  echo main; exit 0
fi
if [ "\$1" = "push" ]; then
  n=\$(cat "$BATS_TEST_TMPDIR/pushes"); echo \$((n + 1)) > "$BATS_TEST_TMPDIR/pushes"
  [ "\$n" -lt "\${GIT_PUSH_FAIL_TIMES:-0}" ] && { echo "! [rejected] (non-fast-forward)" >&2; exit 1; }
fi
exit 0
STUB
  cat > "$repo/bin/make" <<STUB
#!/usr/bin/env bash
echo "make \$*" >> "$CALLS"
[ "\$1" = "\${MAKE_FAIL:-}" ] && exit 1
exit 0
STUB
  cat > "$repo/bin/gh" <<'STUB'
#!/usr/bin/env bash
echo 12
STUB
  chmod +x "$repo/bin/git" "$repo/bin/make" "$repo/bin/gh"
  PATH="$repo/bin:$PATH"
  cd "$repo"
}

@test "lints, tests, adds the given files, commits and pushes, then points at the replies" {
  run "$SCRIPT" a.ts b.ts
  [ "$status" -eq 0 ]
  grep -q '^make lint$' "$CALLS"
  grep -q '^make test$' "$CALLS"
  [ "$(grep -n '^make test$' "$CALLS" | cut -d: -f1)" -lt "$(grep -n '^git add' "$CALLS" | cut -d: -f1)" ]
  [[ "$output" == *"reply-review-thread.sh 12 <thread-id>"* ]]
  grep -q '^git add a.ts b.ts$' "$CALLS"
  grep -q 'git commit --no-verify -m' "$CALLS"
  grep -q '^git push$' "$CALLS"
  ! grep -q 'git pull' "$CALLS"
}

@test "stops before committing when lint or test fails" {
  MAKE_FAIL=test run "$SCRIPT" a.ts
  [ "$status" -eq 1 ]
  [[ "$output" == *"make test failed"* ]]
  ! grep -q '^git add' "$CALLS"
  ! grep -q '^git commit' "$CALLS"
}

@test "with no files pushes an empty commit only, without lint or test" {
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  ! grep -q '^make' "$CALLS"
  ! grep -q '^git add' "$CALLS"
  grep -q 'commit --allow-empty --only' "$CALLS"
}

@test "merges the upstream and pushes again when the remote is ahead" {
  GIT_PUSH_FAIL_TIMES=1 run "$SCRIPT" a.ts
  [ "$status" -eq 0 ]
  grep -q 'git pull --no-rebase --no-edit origin main' "$CALLS"
  [ "$(grep -c '^git push$' "$CALLS")" -eq 2 ]
}

@test "finishes an in-progress merge instead of committing files" {
  GIT_MERGE_IN_PROGRESS=1 run "$SCRIPT" a.ts
  [ "$status" -eq 0 ]
  grep -q '^make test$' "$CALLS"
  grep -q '^git add -A$' "$CALLS"
  grep -q 'commit --no-edit' "$CALLS"
  ! grep -q '^git add a.ts' "$CALLS"
}
