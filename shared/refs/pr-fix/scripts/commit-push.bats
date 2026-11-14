#!/usr/bin/env bats
# commit-push.sh with git and make stubs: lint + test, add + commit + push, the empty commit
# with no files, the retry through push-with-merge when the remote is ahead, and finishing an
# in-progress merge, with the empty commit on top only when the PR has an active thread or a
# failing check.

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/commit-push.sh"
  repo="$BATS_TEST_TMPDIR/repo"
  # No .agents in the repo, as in a worktree without the kit: the script finds its refs beside it
  mkdir -p "$repo/bin"
  CALLS="$BATS_TEST_TMPDIR/calls"
  : > "$CALLS"
  echo 0 > "$BATS_TEST_TMPDIR/pushes"
  cat > "$repo/bin/git" <<STUB
#!/usr/bin/env bash
echo "git \$*" >> "$CALLS"
if [ "\$1" = "rev-parse" ]; then
  case "\$*" in
    *MERGE_HEAD*) [ "\${GIT_MERGE_IN_PROGRESS:-0}" = 1 ] && { echo deadbeef; exit 0; }; exit 1 ;;
    *HEAD^2*) [ "\${GIT_HEAD_IS_MERGE:-0}" = 1 ] && { echo cafe; exit 0; }; exit 1 ;;
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
case "$*" in
  "api graphql"*) [ "${GH_ACTIVE_THREAD:-0}" = 1 ] && echo '### T1 a.ts:3 [active]' ;;
  "pr checks"*) [ "${GH_FAILING_CHECK:-0}" = 1 ] && { echo pass; echo fail; exit 1; }; echo pass ;;
  "repo view"*) echo owner ;;
  *) echo 12 ;;
esac
exit 0
STUB
  chmod +x "$repo/bin/git" "$repo/bin/make" "$repo/bin/gh"
  PATH="$repo/bin:$PATH"
  cd "$repo" || exit
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
  ! grep -q 'git pull' "$CALLS" || false
}

@test "stops before committing when lint or test fails" {
  MAKE_FAIL="test" run "$SCRIPT" a.ts
  [ "$status" -eq 1 ]
  [[ "$output" == *"make test failed"* ]]
  ! grep -q '^git add' "$CALLS" || false
  ! grep -q '^git commit' "$CALLS" || false
}

@test "with no files pushes an empty commit only, without lint or test" {
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  ! grep -q '^make' "$CALLS" || false
  ! grep -q '^git add' "$CALLS" || false
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
  ! grep -q '^git add a.ts' "$CALLS" || false
}

@test "finishing a merge that only resolved a conflict pushes no empty commit" {
  GIT_MERGE_IN_PROGRESS=1 GIT_HEAD_IS_MERGE=1 run "$SCRIPT"
  [ "$status" -eq 0 ]
  ! grep -q 'commit --allow-empty' "$CALLS" || false
  grep -q '^git push$' "$CALLS"
}

@test "finishing a merge on a PR with an active thread pushes the empty commit" {
  GIT_MERGE_IN_PROGRESS=1 GIT_HEAD_IS_MERGE=1 GH_ACTIVE_THREAD=1 run "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -q 'commit --allow-empty --no-verify -m chore: trigger code review after merge' "$CALLS"
}

@test "finishing a merge on a PR with a failing check pushes the empty commit" {
  GIT_MERGE_IN_PROGRESS=1 GIT_HEAD_IS_MERGE=1 GH_FAILING_CHECK=1 run "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -q 'commit --allow-empty --no-verify -m chore: trigger code review after merge' "$CALLS"
}
