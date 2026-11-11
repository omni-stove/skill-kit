#!/usr/bin/env bash
# Create one child issue linked to its parent and print its URL.
#   create.sh --parent <number> [--after <number>[,<number>...]] <bug|implementation> <title> <body>
# Without --after the label goes on at creation, so the worker's labeled event fires exactly once.
# With --after the issue is filed unlabeled, its body naming the issues it waits on and the label
# to add once they merge, so the user can start it by adding that label.
set -euo pipefail

usage() { echo "usage: create.sh --parent <number> [--after <number>[,<number>...]] <bug|implementation> <title> <body>" >&2; exit 2; }
[ "${1:-}" = "--parent" ] && [[ "${2:-}" =~ ^[0-9]+$ ]] || usage
parent="$2"
shift 2
after=
if [ "${1:-}" = "--after" ]; then
  [[ "${2:-}" =~ ^[0-9]+(,[0-9]+)*$ ]] || usage
  after="$2"
  shift 2
fi
[ $# -eq 3 ] || usage
type="$1"
title="$2"
body="$3"
case "$type" in bug|implementation) ;; *) usage ;; esac

if [ -n "$after" ]; then
  waits="#${after//,/ #}"
  body="親: #${parent}
待ち: ${waits}
ラベル: \`${type}\`（待ちのIssueがマージされたら付ける）

${body}"
  url="$("${GH_CMD:-gh}" issue create --title "$title" --body "$body")"
else
  body="親: #${parent}

${body}"
  url="$("${GH_CMD:-gh}" issue create --title "$title" --body "$body" --label "$type")"
fi
echo "$url"

# The worker may already be running once the issue exists; a failed link is a warning so the
# caller does not file the issue again.
child_id="$("${GH_CMD:-gh}" api "repos/{owner}/{repo}/issues/${url##*/}" --jq .id)" &&
  "${GH_CMD:-gh}" api --method POST "repos/{owner}/{repo}/issues/${parent}/sub_issues" -F "sub_issue_id=${child_id}" >/dev/null ||
  echo "warning: could not link ${url} as a sub-issue of #${parent}" >&2
