#!/usr/bin/env bash
# Create one child issue linked to its parent and print its URL.
#   create.sh --parent <number> [--after <number>[,<number>...]] <bug|implementation|manual> <title> --task <text> --check <text>
# The body is a parent line, then the task and how a person checks it done, under fixed headings.
# Without --after the label goes on at creation, so the worker's labeled event fires exactly once.
# With --after the issue is marked blocked by those issues (GitHub's issue dependencies); a bug or
# implementation is filed unlabeled, a bug also getting the Bug issue type, so its label can be
# added once they close. A manual issue is for the user, not the worker, so it is always labeled.
set -euo pipefail

usage() { echo "usage: create.sh --parent <number> [--after <number>[,<number>...]] <bug|implementation|manual> <title> --task <text> --check <text>" >&2; exit 2; }
[ "${1:-}" = "--parent" ] && [[ "${2:-}" =~ ^[0-9]+$ ]] || usage
parent="$2"
shift 2
after=
if [ "${1:-}" = "--after" ]; then
  [[ "${2:-}" =~ ^[0-9]+(,[0-9]+)*$ ]] || usage
  after="$2"
  shift 2
fi
[ $# -eq 6 ] && [ "$3" = --task ] && [ -n "$4" ] && [ "$5" = --check ] && [ -n "$6" ] || usage
type="$1"
title="$2"
body="親: #${parent}

## やること

$4

## 確認方法

$6"
case "$type" in bug|implementation|manual) ;; *) usage ;; esac

if [ "$type" = manual ]; then
  # Repos set up for the worker have bug and implementation but not this one; it already exists after the first run.
  "${GH_CMD:-gh}" label create manual --description "Done by hand on the user's machine, not by the issue worker" >/dev/null 2>&1 || true
fi
if [ -n "$after" ] && [ "$type" != manual ]; then
  url="$("${GH_CMD:-gh}" issue create --title "$title" --body "$body")"
else
  url="$("${GH_CMD:-gh}" issue create --title "$title" --body "$body" --label "$type")"
fi
echo "$url"
number="${url##*/}"

# The worker may already be running once the issue exists; a failed link is a warning so the
# caller does not file the issue again.
issue_id() { "${GH_CMD:-gh}" api "repos/{owner}/{repo}/issues/$1" --jq .id; }
child_id="$(issue_id "$number")" &&
  "${GH_CMD:-gh}" api --method POST "repos/{owner}/{repo}/issues/${parent}/sub_issues" -F "sub_issue_id=${child_id}" >/dev/null ||
  echo "warning: could not link ${url} as a sub-issue of #${parent}" >&2
for a in ${after//,/ }; do
  id="$(issue_id "$a")" &&
    "${GH_CMD:-gh}" api --method POST "repos/{owner}/{repo}/issues/${number}/dependencies/blocked_by" -F "issue_id=${id}" >/dev/null ||
    echo "warning: could not mark ${url} as blocked by #${a}" >&2
done
if [ -n "$after" ] && [ "$type" = bug ]; then
  "${GH_CMD:-gh}" api --method PATCH "repos/{owner}/{repo}/issues/${number}" -f type=Bug >/dev/null ||
    echo "warning: could not set the Bug type on ${url}; it will be labeled implementation when unblocked" >&2
fi
