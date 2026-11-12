#!/usr/bin/env bash
# List the open issues matching the keywords, one per line as <number><TAB><labels><TAB><title><TAB><url>,
# the ones already labeled for the issue worker (bug, implementation) first and
# marked `covers`, as are the ones blocked by other issues and waiting for that label: such an
# issue replaces an item of the split.
# usage: similar.sh <keyword>...
set -euo pipefail
. "$(dirname -- "$0")/../../../refs/prompt.sh"

[ "$#" -ge 1 ] || { echo "usage: similar.sh <keyword>...   (words from the task)" >&2; exit 2; }
blocked=" $("${GH_CMD:-gh}" api --paginate "repos/{owner}/{repo}/issues?state=open&per_page=100" \
  --jq '.[] | select(.issue_dependencies_summary.total_blocked_by > 0) | .number' | tr '\n' ' ')"
"${GH_CMD:-gh}" issue list --search "$*" --state open --limit 30 --json number,title,labels,url |
  jq -r --arg blocked "$blocked" '.[] | .number as $n | ([.labels[].name] | join(",")) as $l
         | (if ($l | test("(^|,)(bug|implementation)(,|$)")) or ($blocked | contains(" \($n) ")) then "covers" else "similar" end) as $k
         | "\($k)\t\(.number)\t\($l)\t\(.title)\t\(.url)"' | sort -t "$(printf '\t')" -k1,1 -k2,2n
prompt similar >&2
