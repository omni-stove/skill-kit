#!/usr/bin/env bats
# push-with-merge.sh — push once on success; on a non-fast-forward rejection pull (merge) and
# push again, with an empty commit when the merge leaves a merge commit at head; exit 3 on a
# conflict without aborting; any other push failure is passed through without a pull.
# The git stub reads: GIT_PUSH_FAIL_TIMES (first N pushes fail), GIT_PUSH_FAIL_MSG (their
# stderr), GIT_PULL_FAIL (pull fails), GIT_HEAD_IS_MERGE (HEAD^2 exists).

HELPER="$BATS_TEST_DIRNAME/push-with-merge.sh"

setup() {
  CALLS="$BATS_TEST_TMPDIR/calls"
  PUSH_COUNT="$BATS_TEST_TMPDIR/push_count"
  : > "$CALLS"
  echo 0 > "$PUSH_COUNT"
  cat > "$BATS_TEST_TMPDIR/git" <<STUB
#!/usr/bin/env bash
echo "git \$*" >> "$CALLS"
if [ "\$1" = rev-parse ]; then
  case "\$*" in
    *HEAD^2*) [ "\${GIT_HEAD_IS_MERGE:-0}" = 1 ] && { echo cafebabe; exit 0; }; exit 1 ;;
  esac
  exit 0
fi
if [ "\$1" = push ]; then
  n=\$(cat "$PUSH_COUNT")
  echo \$((n + 1)) > "$PUSH_COUNT"
  if [ "\$n" -lt "\${GIT_PUSH_FAIL_TIMES:-0}" ]; then
    echo "\${GIT_PUSH_FAIL_MSG:-! [rejected] (non-fast-forward)}" >&2
    exit 1
  fi
fi
if [ "\$1" = pull ] && [ "\${GIT_PULL_FAIL:-0}" = 1 ]; then
  echo "CONFLICT (content): merge conflict" >&2
  exit 1
fi
exit 0
STUB
  chmod +x "$BATS_TEST_TMPDIR/git"
  PATH="$BATS_TEST_TMPDIR:$PATH"
  WRAPPER="$BATS_TEST_TMPDIR/wrapper.sh"
  cat > "$WRAPPER" <<EOS
#!/usr/bin/env bash
set -euo pipefail
source "$HELPER"
push_with_merge "\$@"
EOS
  chmod +x "$WRAPPER"
}

@test "pushes once and does not pull on success" {
  run bash "$WRAPPER"
  [ "$status" -eq 0 ]
  ! grep -q 'git pull' "$CALLS" || false
  [ "$(grep -c 'git push' "$CALLS")" -eq 1 ]
}

@test "forwards extra args to git push" {
  run bash "$WRAPPER" -u origin my-branch
  [ "$status" -eq 0 ]
  grep -q 'git push -u origin my-branch' "$CALLS"
}

@test "merges from the named remote and branch and re-pushes when the first push is rejected" {
  GIT_PUSH_FAIL_TIMES=1 run bash "$WRAPPER" -u origin my-branch
  [ "$status" -eq 0 ]
  grep -q 'git pull --no-rebase --no-edit origin my-branch' "$CALLS"
  [ "$(grep -n 'git push' "$CALLS" | head -1 | cut -d: -f1)" -lt "$(grep -n 'git pull' "$CALLS" | cut -d: -f1)" ]
  [ "$(grep -c 'git push -u origin my-branch' "$CALLS")" -eq 2 ]
}

@test "adds an empty commit before re-pushing when the merge leaves a merge commit at head" {
  GIT_PUSH_FAIL_TIMES=1 GIT_HEAD_IS_MERGE=1 run bash "$WRAPPER" -u origin my-branch
  [ "$status" -eq 0 ]
  grep -q 'git commit --allow-empty' "$CALLS"
  [ "$(grep -n 'git pull' "$CALLS" | cut -d: -f1)" -lt "$(grep -n 'git commit --allow-empty' "$CALLS" | cut -d: -f1)" ]
  [ "$(grep -n 'git commit --allow-empty' "$CALLS" | cut -d: -f1)" -lt "$(grep -n 'git push' "$CALLS" | tail -1 | cut -d: -f1)" ]
  [ "$(grep -c 'git push' "$CALLS")" -eq 2 ]
}

@test "does not add an empty commit when the pull fast-forwards" {
  GIT_PUSH_FAIL_TIMES=1 run bash "$WRAPPER" -u origin my-branch
  [ "$status" -eq 0 ]
  ! grep -q 'git commit --allow-empty' "$CALLS" || false
}

@test "passes a non-mergeable push failure through without pulling" {
  GIT_PUSH_FAIL_TIMES=1 GIT_PUSH_FAIL_MSG='fatal: Authentication failed' run bash "$WRAPPER" -u origin my-branch
  [ "$status" -ne 0 ]
  [ "$status" -ne 3 ]
  ! grep -q 'git pull' "$CALLS" || false
  [ "$(grep -c 'git push' "$CALLS")" -eq 1 ]
}

@test "does not pull on a rejection that a merge cannot fix (stale info)" {
  GIT_PUSH_FAIL_TIMES=1 GIT_PUSH_FAIL_MSG='! [rejected] main -> main (stale info)' run bash "$WRAPPER" -u origin main
  [ "$status" -ne 0 ]
  [ "$status" -ne 3 ]
  ! grep -q 'git pull' "$CALLS" || false
  [ "$(grep -c 'git push' "$CALLS")" -eq 1 ]
}

@test "exits 3 without aborting when the merge conflicts" {
  GIT_PUSH_FAIL_TIMES=1 GIT_PULL_FAIL=1 run bash "$WRAPPER"
  [ "$status" -eq 3 ]
  grep -q 'git pull' "$CALLS"
  ! grep -q 'git merge --abort' "$CALLS" || false
  [ "$(grep -c 'git push' "$CALLS")" -eq 1 ]
}

@test "runs push_with_merge with the given args when executed directly" {
  run bash "$HELPER" -u origin my-branch
  [ "$status" -eq 0 ]
  grep -q 'git push -u origin my-branch' "$CALLS"
}
