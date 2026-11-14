#!/usr/bin/env bats
# fix-prs scan.sh and clean.sh in a real git repo with a gh stub: which PRs count as stuck,
# the worktree each gets with the untracked .agents files linked in, the named PRs, and removing the worktrees.

bats_require_minimum_version 1.5.0

setup() {
  SCAN="$BATS_TEST_DIRNAME/scan.sh"
  CLEAN="$BATS_TEST_DIRNAME/clean.sh"
  repo="$BATS_TEST_TMPDIR/repo"
  # As a synced repo has it: a tracked file under .agents/refs beside the kit's ignored ones,
  # and an untracked, unignored .agents/skills
  mkdir -p "$repo/.agents/skills" "$repo/.agents/refs/pr-fix/scripts"
  cd "$repo" || exit
  git init -q
  echo game > .agents/refs/domain
  git add .agents/refs/domain
  git -c user.name=t -c user.email=t@t commit -q -m init
  printf '.gitignore\npr-fix\n' > .agents/refs/.gitignore
  touch .agents/refs/pr-fix/scripts/fetch.sh
  cat > "$BATS_TEST_TMPDIR/gh" <<'STUB'
#!/usr/bin/env bash
# PR 7 is UNKNOWN for the first $UNKNOWN_CALLS calls, as GitHub answers before computing mergeable
calls=$(( $(cat "$0.calls" 2>/dev/null || echo 0) + 1 )); echo "$calls" > "$0.calls"
m7=CONFLICTING; [ "$calls" -gt "${UNKNOWN_CALLS:-1}" ] || m7=UNKNOWN
pr() { echo "{\"number\":$1,\"title\":\"t$1\",\"url\":\"u$1\",\"isDraft\":$2,\"mergeable\":\"$3\",\"reviewThreads\":{\"nodes\":$4},\"commits\":{\"nodes\":[{\"commit\":{\"statusCheckRollup\":$5}}]}}"; }
out="{\"data\":{\"repository\":{\"pullRequests\":{\"nodes\":[
$(pr 1 false MERGEABLE '[]' '{"state":"SUCCESS"}'),
$(pr 2 false CONFLICTING '[]' '{"state":"SUCCESS"}'),
$(pr 3 false MERGEABLE '[{"isResolved":false,"isOutdated":false}]' '{"state":"FAILURE"}'),
$(pr 4 false MERGEABLE '[{"isResolved":true,"isOutdated":false},{"isResolved":false,"isOutdated":true}]' '{"state":"PENDING"}'),
$(pr 5 true CONFLICTING '[]' '{"state":"ERROR"}'),
$(pr 6 false MERGEABLE '[]' null),
$(pr 7 false "$m7" '[]' '{"state":"SUCCESS"}')
]}}}}"
while [ $# -gt 0 ] && [ "$1" != --jq ]; do shift; done
echo "$out" | jq -r "$2"
STUB
  chmod +x "$BATS_TEST_TMPDIR/gh"
  export GH_CMD="$BATS_TEST_TMPDIR/gh" FIX_PRS_WAIT=0
  common="$(git rev-parse --path-format=absolute --git-common-dir)"
}

@test "scan.sh lists the non-draft PRs with a conflict, a failing check or an active thread" {
  run --separate-stderr "$SCAN"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "$(printf '2\tconflict\t%s\tt2\tu2' "$common/fix-prs/2")" ]
  [ "${lines[1]}" = "$(printf '3\tfailing,threads\t%s\tt3\tu3' "$common/fix-prs/3")" ]
  [ "${lines[2]}" = "$(printf '7\tconflict\t%s\tt7\tu7' "$common/fix-prs/7")" ]
  [ "${#lines[@]}" -eq 3 ]
  [ -L "$common/fix-prs/2/.agents/skills" ]
  [ -f "$common/fix-prs/3/.agents/refs/pr-fix/scripts/fetch.sh" ]
  [ -f "$common/fix-prs/3/.agents/refs/domain" ] && [ ! -L "$common/fix-prs/3/.agents/refs/domain" ]
  [ -z "$(git -C "$common/fix-prs/3" status --porcelain)" ]
  [[ "$stderr" != *warning* ]]
  [[ "$stderr" == *".agents/refs/pr-fix/scripts/fetch.sh"* ]]
  [[ "$stderr" == *"clean.sh"* ]]
}

@test "scan.sh lists only the PRs named and reuses their worktree" {
  run --separate-stderr "$SCAN" 3
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 1 ]
  [ ! -e "$common/fix-prs/2" ]
  run --separate-stderr "$SCAN" 3
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 1 ]
}

@test "scan.sh says there is nothing to fix when no PR is stuck" {
  run --separate-stderr "$SCAN" 1 4
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [[ "$stderr" == "Tell the user that no open PR"* ]]
  run "$SCAN" x
  [ "$status" -eq 2 ]
}

@test "scan.sh stops when GitHub keeps a PR's mergeable UNKNOWN" {
  UNKNOWN_CALLS=99 run --separate-stderr "$SCAN"
  [ "$status" -eq 1 ]
  [[ "$stderr" == *"#7"* ]]
  [ ! -e "$common/fix-prs" ]
  UNKNOWN_CALLS=99 run --separate-stderr "$SCAN" 3
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 1 ]
}

@test "scan.sh stops when the gh call fails" {
  printf '#!/usr/bin/env bash\nexit 1\n' > "$GH_CMD"
  run --separate-stderr "$SCAN"
  [ "$status" -ne 0 ]
  [[ "$stderr" != *"Tell the user"* ]]
}

@test "clean.sh removes the clean worktrees and keeps one with changes" {
  run --separate-stderr "$SCAN"
  touch "$common/fix-prs/3/wip.txt"
  run --separate-stderr "$CLEAN"
  [ "$status" -eq 0 ]
  [ "$output" = "$(printf 'unpushed\t3\t%s' "$common/fix-prs/3")" ]
  [ ! -e "$common/fix-prs/2" ]
  [ -L "$common/fix-prs/3/.agents/skills" ]
  [[ "$stderr" == "Report to the user"* ]]
}
