#!/usr/bin/env bash
# Run make lint and make test, commit the given files and push; with no files, push an
# empty commit that reruns CI without running them. A merge left in progress by fetch.sh is
# committed first, as resolved. Ends with what to do next.
# usage: commit-push.sh [file...]
set -euo pipefail
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"

next() {
  prompt pushed pr="$(gh pr view --json number -q .number 2>/dev/null || echo '<pr>')" >&2
}
check() {
  make lint || { echo "commit-push: make lint failed — fix it, then rerun" >&2; exit 1; }
  make test || { echo "commit-push: make test failed — fix it, then rerun" >&2; exit 1; }
}

# shellcheck source=/dev/null
source .agents/refs/push-with-merge.sh

if git rev-parse -q --verify MERGE_HEAD >/dev/null; then
  echo "==> finishing the in-progress merge" >&2
  check
  git add -A
  git commit --no-edit
  add_empty_commit_if_merge_head
  git push
  next
  exit 0
fi

if [ "$#" -eq 0 ]; then
  git commit --allow-empty --only --no-verify -m "chore: rerun CI"
else
  check
  git add "$@"
  git commit --no-verify -m "fix: address review comments and CI failures"
fi
push_with_merge
next
