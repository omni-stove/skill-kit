#!/usr/bin/env bats
# watch.sh with gh and git stubs: the settled state, the verdict checked against the head's
# date, the automated commits as a diff, and the completion report versus the fix batch.

bats_require_minimum_version 1.5.0

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/watch.sh"
  KIT="$(cd "$BATS_TEST_DIRNAME/../../../../.." && pwd)"
  repo="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$repo/.agents/refs" "$repo/bin"
  ln -s "$KIT/domains/code/refs/review-threads.sh" "$repo/.agents/refs/review-threads.sh"
  CALLS="$BATS_TEST_TMPDIR/calls"; : > "$CALLS"
  export VERDICT_AT=2024-05-02T10:00:00Z VERDICT="Verdict: LGTM" ACTIVE="" RESOLVED="" FAIL=0 LOG="" PORCELAIN=""
  cat > "$repo/bin/gh" <<'STUB'
#!/usr/bin/env bash
echo "gh $*" >> "$CALLS"
case "$*" in
  "pr view 7 --json number"*) echo 7 ;;
  *"--json headRefOid"*) echo abc1234567 ;;
  *"--json headRefName"*) echo feat ;;
  *"--json commits"*) echo 2024-05-01T10:00:00Z ;;
  *"--json comments"*) [ -n "$VERDICT" ] && printf '%s\treviewer\t%s\n' "$VERDICT_AT" "$VERDICT" ;;
  *"--json bucket"*) echo 0 ;;
  *"--json name,bucket"*) printf 'pass\tci\n'; [ "$FAIL" = 1 ] && printf 'fail\tlint\n'; true ;;
  "repo view --json owner"*) echo o ;;
  "repo view --json name"*) echo r ;;
  *"isResolved == false"*) printf '%s\n' "$ACTIVE" ;;
  *"isResolved == true"*) printf '%s\n' "$RESOLVED" ;;
  *"--json state,mergeable"*) echo "OPEN MERGEABLE CLEAN https://github.com/o/r/pull/7" ;;
esac
STUB
  cat > "$repo/bin/git" <<'STUB'
#!/usr/bin/env bash
echo "git $*" >> "$CALLS"
case "$1 $2" in
  "log --format=%H"*) printf '%b' "$LOG" ;;
  "diff "*) echo "DIFF $3" ;;
  "rev-parse --abbrev-ref") echo feat ;;
  "rev-parse --short") echo abc1234 ;;
  "rev-parse HEAD") echo abc1234567 ;;
  "status --porcelain") printf '%s' "$PORCELAIN" ;;
esac
exit 0
STUB
  chmod +x "$repo/bin/gh" "$repo/bin/git"
  PATH="$repo/bin:$PATH"
  cd "$repo"
}

@test "a verdict newer than the head, green checks, no thread: the completion report" {
  run --separate-stderr "$SCRIPT" 7 --interval 0
  [ "$status" -eq 0 ]
  [[ "$output" == *"==> head abc1234567"* ]]
  [[ "$output" == *"branch feat at head, worktree clean"* ]]
  [[ "$output" == *"OPEN MERGEABLE CLEAN"* ]]
  [[ "$stderr" == *"==> next: done when the local state above is clean"* ]]
  [[ "$stderr" != *"Audit the batch"* ]]
}

@test "a verdict older than the head commit does not count" {
  VERDICT_AT=2024-04-30T10:00:00Z run --separate-stderr "$SCRIPT" 7 --interval 0
  [[ "$output" == *"(posted before the head commit at 2024-05-01T10:00:00Z"* ]]
  [[ "$stderr" == *"Audit the batch"* ]]
}

@test "a failing check or an active thread means the fix batch" {
  FAIL=1 run --separate-stderr "$SCRIPT" 7 --interval 0
  [[ "$stderr" == *"commit-push.sh <changed files>"* ]]
  [[ "$stderr" == *"reply-review-thread.sh 7 <thread-id>"* ]]
  ACTIVE=$'### T1 a.ts:3 [active]\n#### @reviewer (now) [comment_id=5]\nfix this' run --separate-stderr "$SCRIPT" 7 --interval 0
  [[ "$output" == *"### T1 a.ts:3"* ]]
  [[ "$stderr" == *"Audit the batch"* ]]
}

@test "a thread resolved without a reply is listed and blocks completion" {
  RESOLVED=$'### T2 b.ts:9 [resolved]\n#### @reviewer (now) [comment_id=6]\nrename\n\n### T3 c.ts:1 [resolved]\n#### @reviewer (now) [comment_id=7]\nx\n#### @me (later) [comment_id=8]\ndone' \
    run --separate-stderr "$SCRIPT" 7 --interval 0
  [[ "$output" == *"==> resolved without a reply"* ]]
  [[ "$output" == *"T2 b.ts:9"* ]]
  [[ "$output" != *"T3 c.ts:1"*"T3"* ]]
  [[ "$stderr" == *"Audit the batch"* ]]
}

@test "the automated commits since the last human commit are listed with their diff" {
  LOG='c3\tclaude[bot]\t[agent-fix] lint\nc2\tclaude[bot]\t[agent-fix] test\nc1\tme\tfeat: x\n' run --separate-stderr "$SCRIPT" 7 --interval 0
  [[ "$output" == *"c3 [agent-fix] lint"* ]]
  [[ "$output" == *"c2 [agent-fix] test"* ]]
  [[ "$output" != *"c1 feat: x"* ]]
  [[ "$output" == *"DIFF c2^..origin/feat"* ]]
  run --separate-stderr "$SCRIPT" 7 --interval 0
  [[ "$output" == *"(none)"* ]]
}

@test "a dirty worktree or a stale local head is named in the completion report" {
  PORCELAIN=" M a.ts" run --separate-stderr "$SCRIPT" 7 --interval 0
  [[ "$output" == *"worktree not clean"* ]]
  [[ "$output" != *"worktree clean"* ]]
}
