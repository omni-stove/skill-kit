#!/usr/bin/env bash
# Print the report of one delegate run: the parent's URL and each child issue as
# <label><TAB><title><TAB><url>, where an issue filed to wait shows `later:<label>` and
# the issues it waits on as a fourth column.
# usage: report.sh <parent-number>
set -euo pipefail
. "$(dirname -- "$0")/../../../refs/prompt.sh"

[ "$#" -eq 1 ] && [[ "$1" =~ ^[0-9]+$ ]] || { echo "usage: report.sh <parent-number>" >&2; exit 2; }
parent="$1"
echo "==> parent"
"${GH_CMD:-gh}" issue view "$parent" --json url -q .url
echo "==> issues"
"${GH_CMD:-gh}" api "repos/{owner}/{repo}/issues/${parent}/sub_issues" \
  --jq '.[] | ([.labels[].name] | join(",")) as $l
         | ([(.body // "") | capture("ラベル: `(?<t>[a-z]+)`")? | .t] | first) as $t
         | if $l == "" and $t != null
           then "later:\($t)\t\(.title)\t\(.html_url)\t\([(.body // "") | capture("待ち: (?<w>[^\n]*)")? | .w] | first // "")"
           else "\($l)\t\(.title)\t\(.html_url)" end'
prompt report >&2
