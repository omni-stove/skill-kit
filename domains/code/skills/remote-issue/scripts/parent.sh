#!/usr/bin/env bash
# Prepare the parent issue that groups one remote-issue run's children, print its number, and
# say what to do next.
#   parent.sh <title> <body>                create a new, unlabeled parent
#   parent.sh --issue <number> <body>       use an existing open issue; the body is added as a comment
# The parent carries no worker label, so the issue worker leaves it alone.
set -euo pipefail
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"

usage() { echo "usage: parent.sh <title> <body> | parent.sh --issue <number> <body>" >&2; exit 2; }
if [ "${1:-}" = "--issue" ]; then
  [ $# -eq 3 ] && [[ "$2" =~ ^[0-9]+$ ]] || usage
  state="$("${GH_CMD:-gh}" issue view "$2" --json state --jq .state)"
  [ "$state" = "OPEN" ] || { echo "parent: #$2 is $state and cannot be the parent" >&2; exit 1; }
  "${GH_CMD:-gh}" issue comment "$2" --body "$3" >/dev/null
  parent="$2"
else
  [ $# -eq 2 ] || usage
  url="$("${GH_CMD:-gh}" issue create --title "$1" --body "$2")"
  parent="${url##*/}"
fi
echo "$parent"
prompt parent parent="$parent" >&2
