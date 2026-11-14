#!/usr/bin/env bash
# Push the current branch, merging the remote branch first when it is ahead. A merge left in
# progress by a conflict is committed first, as resolved. The empty commit that reruns a
# review on a merge head is added only when the branch has an open PR, so a push to main
# that merged main gets none.
# usage: push.sh
set -euo pipefail

[ "$#" -eq 0 ] || { echo "usage: push.sh" >&2; exit 2; }
branch="$(git rev-parse --abbrev-ref HEAD)"
# shellcheck source=/dev/null
source "$(dirname -- "$0")/../../../refs/push-with-merge.sh"

if ! gh pr view --json number >/dev/null 2>&1; then
  add_empty_commit_if_merge_head() { :; }
fi

if git rev-parse -q --verify MERGE_HEAD >/dev/null; then
  echo "==> finishing the in-progress merge" >&2
  git add -A
  git commit --no-edit
  add_empty_commit_if_merge_head
fi

push_with_merge origin "$branch"
