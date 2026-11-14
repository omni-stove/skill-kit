#!/usr/bin/env bash
# Under a parent issue, give each open sub-issue that can start now its own worktree under
# <git common dir>/work-issues/<number> on the branch issue-<number> from the default branch, with
# the repo's untracked .agents files linked in, assign it to the caller, and print one line per
# open sub-issue as <state><TAB><number><TAB><title><TAB><detail>:
#   start    every blocker closed as completed; the worktree was added now and is <detail>
#   working  its worktree exists and no open PR closes it yet; <detail> is the worktree
#   review   an open PR closes it; <detail> is the PR's URL
#   waiting  a blocker is still open; <detail> lists the open ones
#   dropped  no blocker is open but one closed as not planned; <detail> lists those
#   manual   labeled manual, the user's to do by hand; <detail> lists its open blockers
#   worker   labeled for the issue worker (bug, security, prototype, implementation), so left to it
# Ends with what to do next.
# usage: next.sh <parent> [<number>...]   (numbers: dropped sub-issues to start as they stand)
set -euo pipefail
. "$(dirname -- "$0")/../../../refs/prompt.sh"
# command keeps gh from calling this function again when GH_CMD is unset
gh() { command "${GH_CMD:-gh}" "$@"; }

usage() { echo "usage: next.sh <parent> [<number>...]" >&2; exit 2; }
[ $# -ge 1 ] || usage
for n in "$@"; do [[ "$n" =~ ^[0-9]+$ ]] || usage; done
parent="$1"
shift
forced=" $* "
common="$(git rev-parse --path-format=absolute --git-common-dir)"

# Read into a variable first, so a failed call stops the script under set -e instead of reading
# as no sub-issue
subs="$(gh api "repos/{owner}/{repo}/issues/$parent/sub_issues" --paginate \
  --jq '.[] | select(.state == "open")
        | "\(.number)\t\(if any(.labels[]; .name == "manual") then "manual"
                         elif any(.labels[]; .name | IN("bug", "security", "prototype", "implementation")) then "worker"
                         else "-" end)\t\(.title)"')"

base=
active=
manual_left=
dropped_left=
while IFS=$'\t' read -r number owner title; do
  [ -n "$number" ] || continue
  if [ "$owner" = worker ]; then printf 'worker\t%s\t%s\t\n' "$number" "$title"; continue; fi
  blockers="$(gh api "repos/{owner}/{repo}/issues/$number/dependencies/blocked_by" \
    --jq '.[] | "\(.number) \(.state) \(.state_reason)"')"
  open=
  dropped=
  while read -r n s r; do
    [ -n "$n" ] || continue
    if [ "$s" = open ]; then open="$open #$n"
    elif [ "$r" != completed ]; then dropped="$dropped #$n"; fi
  done <<< "$blockers"
  dir="$common/work-issues/$number"
  if [ "$owner" = manual ]; then state=manual; detail="${open# }"; manual_left=1
  elif [ -n "$open" ]; then state=waiting; detail="${open# }"
  elif [ -n "$dropped" ] && [[ "$forced" != *" $number "* ]]; then state=dropped; detail="${dropped# }"; dropped_left=1
  else
    # shellcheck disable=SC2016
    pr="$(gh api graphql -F owner='{owner}' -F repo='{repo}' -F n="$number" -f query='query($owner:String!,$repo:String!,$n:Int!){
  repository(owner:$owner,name:$repo){ issue(number:$n){
    closedByPullRequestsReferences(first:1,includeClosedPrs:false){ nodes{ url } } } }
}' --jq '.data.repository.issue.closedByPullRequestsReferences.nodes[0].url // empty')"
    if [ -n "$pr" ]; then state=review; detail="$pr"
    elif git worktree list --porcelain | grep -qxF "worktree $dir"; then state=working; detail="$dir"
    else
      if [ -z "$base" ]; then
        base="$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name)"
        git fetch origin "$base" >/dev/null 2>&1 \
          || { echo "next: could not fetch origin/$base — check the network and the remote, then rerun" >&2; exit 1; }
      fi
      if git show-ref --verify --quiet "refs/heads/issue-$number"; then
        git worktree add "$dir" "issue-$number" >/dev/null 2>&1
      else
        git worktree add -b "issue-$number" "$dir" "origin/$base" >/dev/null 2>&1
      fi || { echo "next: could not add the worktree $dir for #$number — remove what is there, then rerun" >&2; exit 1; }
      "$(dirname -- "$0")/../../../refs/link-agents.sh" "$dir"
      gh issue edit "$number" --add-assignee @me >/dev/null
      state=start; detail="$dir"
    fi
    active=1
  fi
  printf '%s\t%s\t%s\t%s\n' "$state" "$number" "$title" "$detail"
done <<< "$subs"

if [ -n "$active" ]; then prompt start parent="$parent" >&2
elif [ -n "$subs" ]; then prompt stuck >&2
else prompt finished parent="$parent" >&2; fi
[ -z "$manual_left" ] || prompt manual >&2
[ -z "$dropped_left" ] || prompt dropped parent="$parent" >&2
