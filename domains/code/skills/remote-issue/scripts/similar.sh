#!/usr/bin/env bash
# List the open issues matching the keywords, one per line as <number><TAB><labels><TAB><title><TAB><url>,
# the ones already labeled for the issue worker (bug, prototype, implementation) first and
# marked `covers`: such an issue replaces an item of the split.
# usage: similar.sh <keyword>...
set -euo pipefail
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"

[ "$#" -ge 1 ] || { echo "usage: similar.sh <keyword>...   (words from the task)" >&2; exit 2; }
"${GH_CMD:-gh}" issue list --search "$*" --state open --limit 30 --json number,title,labels,url \
  --jq '.[] | ([.labels[].name] | join(",")) as $l
         | (if ($l | test("(^|,)(bug|prototype|implementation)(,|$)")) then "covers" else "similar" end) as $k
         | "\($k)\t\(.number)\t\($l)\t\(.title)\t\(.url)"' | sort -t "$(printf '\t')" -k1,1 -k2,2n
prompt similar >&2
