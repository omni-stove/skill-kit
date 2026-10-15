#!/usr/bin/env bash
# Commit the given files and push; with no files, push an empty commit that reruns CI.
# A merge left in progress by fetch.sh is committed first, as resolved.
# usage: commit-push.sh [file...]
set -euo pipefail

# shellcheck source=/dev/null
source .agents/refs/push-with-merge.sh

if git rev-parse -q --verify MERGE_HEAD >/dev/null; then
  echo "==> finishing the in-progress merge" >&2
  git add -A
  git commit --no-edit
  add_empty_commit_if_merge_head
  git push
  exit 0
fi

if [ "$#" -eq 0 ]; then
  git commit --allow-empty --only --no-verify -m "chore: rerun CI"
else
  git add "$@"
  git commit --no-verify -m "fix: address review comments and CI failures"
fi
push_with_merge
