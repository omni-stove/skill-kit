#!/usr/bin/env bash
# Print the report of one remote-issue run: the parent's URL, each child issue as
# <label><TAB><title><TAB><url>, and the parent's unchecked checklist items (the deferred work).
# usage: report.sh <parent-number>
set -euo pipefail
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"

[ "$#" -eq 1 ] && [[ "$1" =~ ^[0-9]+$ ]] || { echo "usage: report.sh <parent-number>" >&2; exit 2; }
parent="$1"
echo "==> parent"
"${GH_CMD:-gh}" issue view "$parent" --json url -q .url
echo "==> issues"
"${GH_CMD:-gh}" api "repos/{owner}/{repo}/issues/${parent}/sub_issues" \
  --jq '.[] | "\([.labels[].name] | join(","))\t\(.title)\t\(.html_url)"'
echo "==> deferred"
"${GH_CMD:-gh}" issue view "$parent" --json body -q .body | grep -E '^\s*[-*] \[ \]' || echo "(none)"
prompt report >&2
