#!/usr/bin/env bash
# Wait until a PR merges, closes, or is held up by a merge conflict, a failing check or an active
# review thread, then say what to do next. On a merge it removes the issue's worktree under
# <git common dir>/work-issues/ and its branch when nothing is left in them; when held up it prints
# <reasons>, a comma list of conflict, failing and threads.
# usage: wait.sh <parent> <pr number or url>
set -euo pipefail
. "$(dirname -- "$0")/../../../refs/prompt.sh"
gh() { command "${GH_CMD:-gh}" "$@"; }

[ $# -eq 2 ] && [[ "$1" =~ ^[0-9]+$ ]] || { echo "usage: wait.sh <parent> <pr number or url>" >&2; exit 2; }
parent="$1"
pr="$(gh pr view "$2" --json number --jq .number)"
common="$(git rev-parse --path-format=absolute --git-common-dir)"

read -r -d '' jq_expr <<'JQ' || true
.data.repository.pullRequest
| [ (if .mergeable == "CONFLICTING" then "conflict" else empty end),
    (if ((.commits.nodes[0].commit.statusCheckRollup.state // "") | IN("FAILURE", "ERROR")) then "failing" else empty end),
    (if any(.reviewThreads.nodes[]; .isResolved == false and .isOutdated == false) then "threads" else empty end) ] as $r
| "\(.state)\t\(.headRefName)\t\(.url)\t\($r | join(","))"
JQ

while :; do
  # shellcheck disable=SC2016
  line="$(gh api graphql -F owner='{owner}' -F repo='{repo}' -F n="$pr" -f query='query($owner:String!,$repo:String!,$n:Int!){
  repository(owner:$owner,name:$repo){ pullRequest(number:$n){
    state mergeable headRefName url
    reviewThreads(first:100){ nodes{ isResolved isOutdated } }
    commits(last:1){ nodes{ commit{ statusCheckRollup{ state } } } } } }
}' --jq "$jq_expr")"
  IFS=$'\t' read -r state head url reasons <<< "$line"
  dir="$common/work-issues/${head#issue-}"
  case "$state" in
    MERGED)
      if git worktree list --porcelain | grep -qxF "worktree $dir"; then
        git worktree remove "$dir" 2>/dev/null && git branch -D "$head" >/dev/null 2>&1 \
          || echo "wait: $dir holds changes or untracked files, so it is kept" >&2
      fi
      prompt merged pr="$url" parent="$parent" >&2
      exit 0 ;;
    CLOSED)
      prompt closed pr="$url" parent="$parent" >&2
      exit 0 ;;
  esac
  if [ -n "$reasons" ]; then
    echo "$reasons"
    prompt fix pr="$url" parent="$parent" worktree="$dir" >&2
    exit 0
  fi
  sleep "${WORK_ISSUES_WAIT:-60}"
done
