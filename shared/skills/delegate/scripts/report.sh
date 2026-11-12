#!/usr/bin/env bash
# Print the report of one delegate run: the parent's URL and each child issue as
# <label><TAB><title><TAB><url>, where an unlabeled one filed to wait shows `later:<label>`
# (bug for the Bug issue type) and the issues blocking it as a fourth column, as does a manual one.
# usage: report.sh <parent-number>
set -euo pipefail
. "$(dirname -- "$0")/../../../refs/prompt.sh"

[ "$#" -eq 1 ] && [[ "$1" =~ ^[0-9]+$ ]] || { echo "usage: report.sh <parent-number>" >&2; exit 2; }
parent="$1"
echo "==> parent"
"${GH_CMD:-gh}" issue view "$parent" --json url -q .url
echo "==> issues"
"${GH_CMD:-gh}" api "repos/{owner}/{repo}/issues/${parent}/sub_issues" --paginate \
  --jq '.[] | "\(.number)\t\([.labels[].name] | join(",") | if . == "" then "-" else . end)\t\(if .type.name == "Bug" then "bug" else "implementation" end)\t\(.title)\t\(.html_url)"' |
while IFS=$'\t' read -r number labels type title url; do
  if [ "$labels" = manual ]; then
    waits="$("${GH_CMD:-gh}" api "repos/{owner}/{repo}/issues/${number}/dependencies/blocked_by" --jq '[.[] | "#\(.number)"] | join(" ")')"
    printf 'manual\t%s\t%s\t%s\n' "$title" "$url" "$waits"
  elif [ "$labels" != - ]; then
    printf '%s\t%s\t%s\n' "$labels" "$title" "$url"
  else
    waits="$("${GH_CMD:-gh}" api "repos/{owner}/{repo}/issues/${number}/dependencies/blocked_by" --jq '[.[] | "#\(.number)"] | join(" ")')"
    printf 'later:%s\t%s\t%s\t%s\n' "$type" "$title" "$url" "$waits"
  fi
done
prompt report >&2
