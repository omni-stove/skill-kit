#!/usr/bin/env bash
# Check out a PR's branch with the remote's latest commits merged in, merge the base branch,
# print the PR's state, active review threads, checks and changed files, and say what to do next.
# usage: fetch.sh [pr-number-or-url-or-branch]   (none: the current branch's PR)
set -euo pipefail

[ "$#" -le 1 ] || { echo "usage: fetch.sh [pr-number-or-url-or-branch]" >&2; exit 2; }
if [ "$#" -eq 0 ]; then
  pr="$(gh pr view --json number -q .number)"
  echo "==> resolved PR from current branch: #$pr"
else
  pr="$(gh pr view "$1" --json number -q .number)"
  [ "$pr" = "$1" ] || echo "==> resolved PR from '$1': #$pr"
fi

echo "==> PR state"
gh pr view "$pr" --json title,body,state,mergeable,mergeStateStatus,headRefName,headRefOid,baseRefName
head_ref="$(gh pr view "$pr" --json headRefName -q .headRefName)"
base_ref="$(gh pr view "$pr" --json baseRefName -q .baseRefName)"

echo "==> checkout PR branch"
gh pr checkout "$pr" || echo "==> gh pr checkout could not fast-forward; merging the remote head below"
cur_branch="$(git symbolic-ref --quiet --short HEAD || echo '')"
[ "$cur_branch" = "$head_ref" ] || { echo "fetch: on '${cur_branch:-DETACHED}', not the PR branch '${head_ref}' — switch to it by hand, then rerun" >&2; exit 4; }

echo "==> merge remote PR head (pulls agent-fix commits)"
git fetch origin "refs/pull/${pr}/head"
before="$(git rev-parse HEAD)"
git merge FETCH_HEAD
pulled="$(git log --format='%h %an %s' "${before}..HEAD")"
if [ -n "$pulled" ]; then
  echo "==> commits pulled from the remote head"
  printf '%s\n' "$pulled"
  echo "==> next: if a pulled commit strays from the PR's intent, show it and ask the user before fixing" >&2
fi

echo "==> merge latest origin/${base_ref}"
git fetch origin "$base_ref"
git merge "origin/${base_ref}" || { echo "fetch: merge conflict — resolve the conflicts, then continue with commit-push.sh" >&2; exit 3; }

.agents/refs/review-threads.sh "$pr" --active

echo "==> CI checks"
gh pr checks "$pr" || true

echo "==> changed files"
gh pr diff "$pr" --name-only

echo "==> next: fix the active threads, the failing checks and any conflict with the smallest change that holds the root cause; leave a test's assertions and unrelated code as they are; skip a finding that is wrong or outside the PR's scope and say why in your reply to it. Then run .agents/skills/fix-pr/scripts/commit-push.sh <changed files> (no arguments when nothing changed)" >&2
