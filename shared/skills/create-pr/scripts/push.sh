#!/usr/bin/env bash
# Push the current branch, merging the upstream first when the remote is ahead, then say
# what follows: open.sh when the branch has no PR yet, the report when the push updated one.
# usage: push.sh
set -euo pipefail
. "$(dirname -- "$0")/../../../refs/prompt.sh"

[ "$#" -eq 0 ] || { echo "usage: push.sh" >&2; exit 2; }
branch="$(git rev-parse --abbrev-ref HEAD)"
# shellcheck source=/dev/null
source .agents/refs/push-with-merge.sh
push_with_merge -u origin "$branch"

url="$(gh pr view --json url -q .url 2>/dev/null || true)"
if [ -n "$url" ]; then
  prompt updated url="$url" >&2
else
  prompt no-pr >&2
fi
