#!/usr/bin/env bash
# Push the current branch and open a PR that closes the issue, assigned to the caller, then
# print its URL and what to do next.
# usage: pr.sh <issue> <title> <body>
set -euo pipefail
. "$(dirname -- "$0")/../../../refs/prompt.sh"
gh() { command "${GH_CMD:-gh}" "$@"; }

[ $# -eq 3 ] && [[ "$1" =~ ^[0-9]+$ ]] && [ -n "$2" ] && [ -n "$3" ] || { echo "usage: pr.sh <issue> <title> <body>" >&2; exit 2; }
[ -z "$(git status --porcelain)" ] || { echo "pr: uncommitted changes — commit them, then rerun" >&2; exit 1; }
git push -u origin HEAD >&2
gh pr create --title "$2" --assignee @me --body "$3

Closes #$1"
prompt opened >&2
