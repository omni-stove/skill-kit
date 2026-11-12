#!/usr/bin/env bash
# Under each open parent issue, find the open sub-issues not yet labeled for the worker, add the
# label to each one whose blocking issues (GitHub's "blocked by") all closed as completed, and print
# one line per such sub-issue as <state><TAB><number><TAB><label><TAB><title><TAB><url><TAB><blockers>:
#   labeled  every blocker completed; the label was added now
#   waiting  a blocker is still open; <blockers> lists the open ones
#   dropped  no blocker is open but one closed as not planned; <blockers> lists those
#   unlinked no blocker is set, so nothing tells when it may start
# The label is bug for an issue of type Bug and implementation otherwise.
#   scan.sh [<parent>...]         scan these parents, or every open issue with open sub-issues
#   scan.sh --force <number>...   add the label to these open unlabeled issues whatever their blockers
set -euo pipefail
. "$(dirname -- "$0")/../../../refs/prompt.sh"
gh() { "${GH_CMD:-gh}" "$@"; }

usage() { echo "usage: scan.sh [<parent>...] | scan.sh --force <number>..." >&2; exit 2; }
force=
if [ "${1:-}" = "--force" ]; then
  shift
  [ $# -ge 1 ] || usage
  force=1
fi
for n in "$@"; do [[ "$n" =~ ^[0-9]+$ ]] || usage; done

# <number><TAB><label><TAB><title><TAB><url> of an issue still waiting for the worker's label
pending='select(.state == "open" and ([.labels[].name] | index("bug") or index("implementation") | not))
         | "\(.number)\t\(if .type.name == "Bug" then "bug" else "implementation" end)\t\(.title)\t\(.html_url)"'

if [ -n "$force" ]; then
  for n in "$@"; do
    line="$(gh api "repos/{owner}/{repo}/issues/$n" --jq "$pending")"
    [ -n "$line" ] || { echo "scan: #$n is closed or already labeled — run scan.sh to list the waiting issues" >&2; exit 1; }
    IFS=$'\t' read -r number label title url <<< "$line"
    gh issue edit "$number" --add-label "$label" >/dev/null
    printf 'labeled\t%s\t%s\t%s\t%s\t\n' "$number" "$label" "$title" "$url"
  done
  exit 0
fi

parents=("$@")
if [ ${#parents[@]} -eq 0 ]; then
  while read -r p; do [ -n "$p" ] && parents+=("$p"); done < <(
    gh api --paginate "repos/{owner}/{repo}/issues?state=open&per_page=100" \
      --jq '.[] | select(.pull_request == null and .sub_issues_summary.total > .sub_issues_summary.completed) | .number')
fi

for p in ${parents[@]+"${parents[@]}"}; do
  while IFS=$'\t' read -r number label title url; do
    [ -n "$number" ] || continue
    blockers="$(gh api "repos/{owner}/{repo}/issues/$number/dependencies/blocked_by" \
      --jq '.[] | "\(.number) \(.state) \(.state_reason)"')"
    open=
    dropped=
    while read -r n s r; do
      [ -n "$n" ] || continue
      if [ "$s" = open ]; then open="$open #$n"
      elif [ "$r" != completed ]; then dropped="$dropped #$n"; fi
    done <<< "$blockers"
    if [ -z "$blockers" ]; then state=unlinked; left=
    elif [ -n "$open" ]; then state=waiting; left="${open# }"
    elif [ -n "$dropped" ]; then state=dropped; left="${dropped# }"
    else state=labeled; left=; fi
    [ "$state" = labeled ] && gh issue edit "$number" --add-label "$label" >/dev/null
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$state" "$number" "$label" "$title" "$url" "$left"
  done < <(gh api "repos/{owner}/{repo}/issues/$p/sub_issues" --paginate --jq ".[] | $pending")
done
prompt scan >&2
