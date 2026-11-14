#!/usr/bin/env bash
# Find the open, non-draft PRs held up by a merge conflict, a failing check or an active review
# thread, give each its own worktree under <git common dir>/fix-prs/<number> with the repo's
# .agents linked in, and print one line per PR as
#   <number><TAB><reasons><TAB><worktree><TAB><title><TAB><url>
# <reasons> is a comma list of conflict, failing and threads. Ends with what to do next.
# usage: scan.sh [<pr number>...]   (none: every open PR)
set -euo pipefail
. "$(dirname -- "$0")/../../../refs/prompt.sh"
# command keeps gh from calling this function again when GH_CMD is unset
gh() { command "${GH_CMD:-gh}" "$@"; }

for n in "$@"; do [[ "$n" =~ ^[0-9]+$ ]] || { echo "usage: scan.sh [<pr number>...]" >&2; exit 2; }; done

root="$(git rev-parse --show-toplevel)"
common="$(git rev-parse --path-format=absolute --git-common-dir)"

read -r -d '' jq_expr <<'JQ' || true
.data.repository.pullRequests.nodes[]
| select(.isDraft | not)
| [ (if .mergeable == "CONFLICTING" then "conflict" else empty end),
    (if ((.commits.nodes[0].commit.statusCheckRollup.state // "") | IN("FAILURE", "ERROR")) then "failing" else empty end),
    (if any(.reviewThreads.nodes[]; .isResolved == false and .isOutdated == false) then "threads" else empty end) ] as $r
| select($r | length > 0)
| "\(.number)\t\($r | join(","))\t\(.title)\t\(.url)"
JQ

# Read into a variable first, so a failed call stops the script under set -e instead of
# reading as no stuck PR
# shellcheck disable=SC2016
prs="$(gh api graphql --paginate -F owner='{owner}' -F repo='{repo}' -f query='query($owner:String!,$repo:String!,$endCursor:String){
  repository(owner:$owner,name:$repo){
    pullRequests(states:OPEN,first:50,after:$endCursor){
      pageInfo{hasNextPage endCursor}
      nodes{
        number title url isDraft mergeable
        reviewThreads(first:100){ nodes{ isResolved isOutdated } }
        commits(last:1){ nodes{ commit{ statusCheckRollup{ state } } } }
      }
    }
  }
}' --jq "$jq_expr")"

found=
while IFS=$'\t' read -r number reasons title url; do
  [ -n "$number" ] || continue
  if [ $# -gt 0 ]; then
    named=
    for n in "$@"; do [ "$n" = "$number" ] && named=1; done
    [ -n "$named" ] || continue
  fi
  dir="$common/fix-prs/$number"
  if ! git worktree list --porcelain | grep -qxF "worktree $dir"; then
    git worktree add --detach "$dir" >/dev/null 2>&1 \
      || { echo "scan: could not add the worktree $dir for #$number — remove what is there, then rerun" >&2; exit 1; }
  fi
  if [ ! -e "$dir/.agents" ]; then
    ln -s "$root/.agents" "$dir/.agents"
    git -C "$dir" check-ignore -q .agents || echo /.agents >> "$common/info/exclude"
  fi
  printf '%s\t%s\t%s\t%s\t%s\n' "$number" "$reasons" "$dir" "$title" "$url"
  found=1
done <<< "$prs"

if [ -n "$found" ]; then prompt scan clean="$(dirname -- "$0")/clean.sh" >&2; else prompt none >&2; fi
