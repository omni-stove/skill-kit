#!/usr/bin/env bash
# Create one child issue with the label that fires the issue worker, linked to its parent,
# and print its URL.
#   create.sh --parent <number> <bug|prototype|implementation> <title> <body>
# The label goes on at creation so the worker's labeled event fires exactly once.
set -euo pipefail

usage() { echo "usage: create.sh --parent <number> <bug|prototype|implementation> <title> <body>" >&2; exit 2; }
[ "${1:-}" = "--parent" ] && [[ "${2:-}" =~ ^[0-9]+$ ]] || usage
parent="$2"
shift 2
[ $# -eq 3 ] || usage
type="$1"
title="$2"
body="$3"
case "$type" in bug|prototype|implementation) ;; *) usage ;; esac

body="親: #${parent}

${body}"
url="$("${GH_CMD:-gh}" issue create --title "$title" --body "$body" --label "$type")"
echo "$url"

# The worker is already running once the issue exists; a failed link is a warning so the
# caller does not file the issue again.
child_id="$("${GH_CMD:-gh}" api "repos/{owner}/{repo}/issues/${url##*/}" --jq .id)" &&
  "${GH_CMD:-gh}" api --method POST "repos/{owner}/{repo}/issues/${parent}/sub_issues" -F "sub_issue_id=${child_id}" >/dev/null ||
  echo "warning: could not link ${url} as a sub-issue of #${parent}" >&2
