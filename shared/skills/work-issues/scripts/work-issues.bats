#!/usr/bin/env bats
# work-issues next.sh and wait.sh — which sub-issues start in a worktree, and how a PR's wait ends.

bats_require_minimum_version 1.5.0

setup() {
  NEXT="$BATS_TEST_DIRNAME/next.sh"
  WAIT="$BATS_TEST_DIRNAME/wait.sh"
  CALLS="$BATS_TEST_TMPDIR/calls"
  : > "$CALLS"
  remote="$BATS_TEST_TMPDIR/remote.git"
  repo="$BATS_TEST_TMPDIR/repo"
  git init -q --bare -b main "$remote"
  git init -q -b main "$repo"
  cd "$repo" || exit
  git config user.email t@t
  git config user.name t
  mkdir -p .agents/skills
  touch README .agents/skills/x
  git add README
  git commit -qm init
  git remote add origin "$remote"
  git push -q origin main
  common="$(git rev-parse --path-format=absolute --git-common-dir)"
  PR_STATE="${PR_STATE:-OPEN}"
  cat > "$BATS_TEST_TMPDIR/gh" <<STUB
#!/usr/bin/env bash
echo "gh \$*" >> "$CALLS"
issue() { echo "{\"number\":\$1,\"state\":\"\$2\",\"labels\":\$3,\"title\":\"t\$1\"}"; }
reply() { case "\$*" in
  *"issues/3/sub_issues"*) echo "[\$(issue 10 open '[]'),\$(issue 11 open '[]'),\$(issue 12 open '[]'),\$(issue 13 open '[{"name":"manual"}]'),\$(issue 14 open '[]'),\$(issue 15 closed '[]'),\$(issue 16 open '[{"name":"bug"}]')]" ;;
  *"issues/4/sub_issues"*) echo "[\$(issue 15 closed '[]')]" ;;
  *"issues/5/sub_issues"*) echo "[\$(issue 11 open '[]')]" ;;
  *"issues/10/dependencies"*) echo '[{"number":1,"state":"closed","state_reason":"completed"}]' ;;
  *"issues/11/dependencies"*) echo '[{"number":10,"state":"open","state_reason":null}]' ;;
  *"issues/12/dependencies"*) echo '[{"number":6,"state":"closed","state_reason":"not_planned"}]' ;;
  *"issues/13/dependencies"*) echo '[]' ;;
  *"issues/14/dependencies"*) echo '[]' ;;
  *"n=10 "*) echo '{"data":{"repository":{"issue":{"closedByPullRequestsReferences":{"nodes":[]}}}}}' ;;
  *"n=12 "*) echo '{"data":{"repository":{"issue":{"closedByPullRequestsReferences":{"nodes":[]}}}}}' ;;
  *"n=14 "*) echo '{"data":{"repository":{"issue":{"closedByPullRequestsReferences":{"nodes":[{"url":"pr14"}]}}}}}' ;;
  *"n=7 "*) echo "{\"data\":{\"repository\":{\"pullRequest\":{\"state\":\"\$(cat "$BATS_TEST_TMPDIR/state")\",\"mergeable\":\"MERGEABLE\",\"headRefName\":\"issue-10\",\"url\":\"pr7\",\"reviewThreads\":{\"nodes\":\$(cat "$BATS_TEST_TMPDIR/threads")},\"commits\":{\"nodes\":[{\"commit\":{\"statusCheckRollup\":null}}]}}}}}" ;;
  *"repo view"*) echo '{"defaultBranchRef":{"name":"main"}}' ;;
  *"pr view"*) echo '{"number":7}' ;;
esac; }
out=\$(reply "\$@")
while [ \$# -gt 0 ] && [ "\$1" != --jq ]; do shift; done
if [ -n "\$out" ]; then if [ \$# -ge 2 ]; then echo "\$out" | jq -r "\$2"; else echo "\$out"; fi; fi
STUB
  chmod +x "$BATS_TEST_TMPDIR/gh"
  export GH_CMD="$BATS_TEST_TMPDIR/gh"
  echo OPEN > "$BATS_TEST_TMPDIR/state"
  echo '[]' > "$BATS_TEST_TMPDIR/threads"
  export WORK_ISSUES_WAIT=0
}

@test "next.sh starts the ready sub-issues in worktrees and lists the rest" {
  run --separate-stderr "$NEXT" 3
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "$(printf 'start\t10\tt10\t%s' "$common/work-issues/10")" ]
  [ "${lines[1]}" = "$(printf 'waiting\t11\tt11\t#10')" ]
  [ "${lines[2]}" = "$(printf 'dropped\t12\tt12\t#6')" ]
  [ "${lines[3]}" = "$(printf 'manual\t13\tt13\t')" ]
  [ "${lines[4]}" = "$(printf 'review\t14\tt14\tpr14')" ]
  [ "${lines[5]}" = "$(printf 'worker\t16\tt16\t')" ]
  [ "${#lines[@]}" -eq 6 ]
  ! grep -q 'issues/16/dependencies' "$CALLS" || false
  [ "$(git -C "$common/work-issues/10" rev-parse --abbrev-ref HEAD)" = issue-10 ]
  [ -e "$common/work-issues/10/.agents/skills/x" ] && [ -z "$(git -C "$common/work-issues/10" status --porcelain)" ]
  grep -q 'issue edit 10 --add-assignee @me' "$CALLS"
  [ "$(grep -c 'issue edit' "$CALLS")" -eq 1 ]
  [[ "$stderr" == "Launch one Agent"* ]]
  [[ "$stderr" == *"manual lines"* ]]
  [[ "$stderr" == *"next.sh 3 <number>"* ]]
}

@test "next.sh reports a worktree it added before as working, and starts a dropped one it is named" {
  "$NEXT" 3 2>/dev/null
  run --separate-stderr "$NEXT" 3 12
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "$(printf 'working\t10\tt10\t%s' "$common/work-issues/10")" ]
  [ "${lines[2]}" = "$(printf 'start\t12\tt12\t%s' "$common/work-issues/12")" ]
  [ "$(grep -c 'issue edit 10' "$CALLS")" -eq 1 ]
}

@test "next.sh says nothing can start, or that every sub-issue is closed" {
  run --separate-stderr "$NEXT" 5
  [ "$status" -eq 0 ]
  [ "$output" = "$(printf 'waiting\t11\tt11\t#10')" ]
  [[ "$stderr" == "Nothing can start now"* ]]
  run --separate-stderr "$NEXT" 4
  [ -z "$output" ]
  [[ "$stderr" == "Tell the user every sub-issue of #4 is closed."* ]]
  run "$NEXT"
  [ "$status" -eq 2 ]
  run "$NEXT" 3 x
  [ "$status" -eq 2 ]
}

@test "wait.sh says what holds a PR up" {
  echo '[{"isResolved":false,"isOutdated":false}]' > "$BATS_TEST_TMPDIR/threads"
  run --separate-stderr "$WAIT" 3 7
  [ "$status" -eq 0 ]
  [ "$output" = threads ]
  [[ "$stderr" == *"cd $common/work-issues/10 && <command>"* ]]
  [[ "$stderr" == *"wait.sh 3 pr7"* ]]
}

@test "wait.sh removes the issue's worktree and branch once the PR merges" {
  "$NEXT" 3 2>/dev/null
  echo MERGED > "$BATS_TEST_TMPDIR/state"
  run --separate-stderr "$WAIT" 3 7
  [ "$status" -eq 0 ]
  [ ! -d "$common/work-issues/10" ]
  ! git show-ref --verify --quiet refs/heads/issue-10 || false
  [[ "$stderr" == "Stop the agent that opened pr7"*"next.sh 3"* ]]
}

@test "wait.sh keeps a merged issue's worktree that holds changes" {
  "$NEXT" 3 2>/dev/null
  echo x > "$common/work-issues/10/new"
  echo MERGED > "$BATS_TEST_TMPDIR/state"
  run --separate-stderr "$WAIT" 3 7
  [ "$status" -eq 0 ]
  [ -d "$common/work-issues/10" ]
  [[ "$stderr" == *"is kept"* ]]
}
