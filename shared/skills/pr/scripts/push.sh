#!/usr/bin/env bash
# Merge the latest base branch, push the current branch (merging the upstream first when the
# remote is ahead), then say what follows: open.sh when the branch has no PR yet, the report
# when the push updated one.
# The base is the open PR's base when there is one, else the argument (default main).
# usage: push.sh [base-branch]
set -euo pipefail
. "$(dirname -- "$0")/../../../refs/prompt.sh"

[ "$#" -le 1 ] || { echo "usage: push.sh [base-branch]" >&2; exit 2; }
branch="$(git rev-parse --abbrev-ref HEAD)"
# shellcheck source=/dev/null
source .agents/refs/push-with-merge.sh

base="$(gh pr view --json baseRefName -q .baseRefName 2>/dev/null || true)"
base="${base:-${1:-main}}"
# A branch cut from an old base opens as a conflicting PR; merging the base here surfaces the
# conflict locally, where it can be resolved before anyone reviews. A merge, not a rebase, so
# pushed commits are never rewritten.
git fetch origin "$base" >&2
if ! git merge-base --is-ancestor "origin/$base" HEAD; then
  echo "==> merging origin/$base" >&2
  if ! git merge --no-edit "origin/$base" >&2; then
    echo "==> merge conflict with origin/$base: resolve the conflicts in the files above, commit, then rerun this command." >&2
    exit 3
  fi
  add_empty_commit_if_merge_head
fi

push_with_merge -u origin "$branch"

url="$(gh pr view --json url -q .url 2>/dev/null || true)"
if [ -n "$url" ]; then
  prompt updated url="$url" >&2
else
  prompt no-pr >&2
fi
