#!/usr/bin/env bash
# Run make lint and make test, commit the given files and push; with no files, push an
# empty commit that reruns CI without running them. A merge left in progress by fetch.sh is
# committed first, as resolved, with an empty commit on top to rerun the review unless the
# PR has no active review thread and no failing check, as when a conflict was its only
# problem. Ends with what to do next.
# usage: commit-push.sh [file...]
set -euo pipefail
. "$(dirname -- "$0")/../../prompt.sh"

next() {
  prompt pushed pr="$(gh pr view --json number -q .number 2>/dev/null || echo '<pr>')" >&2
}
# True when the PR has an active review thread or a failing check, so the merge commit holds
# more than a conflict resolution; also true when the PR or its threads cannot be read.
more_than_conflict() {
  local pr threads buckets
  pr="$(gh pr view --json number -q .number)" || return 0
  threads="$("$(dirname -- "$0")/../../review-threads.sh" "$pr" --active)" || return 0
  grep -q '^### ' <<<"$threads" && return 0
  # gh pr checks exits non-zero for a failing or pending check, with the list still printed
  buckets="$(gh pr checks "$pr" --json bucket -q '.[].bucket' 2>/dev/null || true)"
  grep -qx fail <<<"$buckets"
}
check() {
  make lint || { echo "commit-push: make lint failed — fix it, then rerun" >&2; exit 1; }
  make test || { echo "commit-push: make test failed — fix it, then rerun" >&2; exit 1; }
}

# shellcheck source=/dev/null
source "$(dirname -- "$0")/../../push-with-merge.sh"

if git rev-parse -q --verify MERGE_HEAD >/dev/null; then
  echo "==> finishing the in-progress merge" >&2
  check
  git add -A
  git commit --no-edit
  if more_than_conflict; then
    add_empty_commit_if_merge_head
  fi
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
