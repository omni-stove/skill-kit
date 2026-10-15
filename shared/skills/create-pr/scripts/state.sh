#!/usr/bin/env bash
# Print the current branch's PR state on stdout — STATE<TAB>URL, NONE when the branch has
# no PR, ON_BASE when on the base branch itself — then the changes the PR carries (status,
# recent commit subjects, the diff against the base) and the next step on stderr.
# usage: state.sh [base-branch]   (default: main)
set -euo pipefail

[ "$#" -le 1 ] || { echo "usage: state.sh [base-branch]" >&2; exit 2; }
base="${1:-main}"

# The base branch is protected: nothing is pushed to it and no PR is opened from it, so the
# PR is not even looked up there.
if [ "$(git rev-parse --abbrev-ref HEAD)" = "$base" ]; then
  printf 'ON_BASE\n'
  git fetch origin "$base" >&2
  echo "==> next: git switch -c <new-branch> origin/$base (uncommitted changes come along), then commit there" >&2
  exit 0
fi

changes() {
  git fetch origin "$base" >&2
  echo "==> changes (git status)"
  git status --short
  echo "==> recent commit subjects (the message style)"
  git log -8 --format='%s'
  echo "==> diff against origin/$base"
  git --no-pager diff "origin/$base"
}

state_url="$(gh pr view --json state,url -q '[.state, .url] | @tsv' 2>/dev/null || true)"
if [ -z "$state_url" ]; then
  printf 'NONE\n'
  changes
  echo "==> next: decide from the changes above what the PR carries and the wording, then run .agents/skills/create-pr/scripts/regenerate.sh" >&2
  exit 0
fi

printf '%s\n' "$state_url"
if [ "${state_url%%	*}" = "OPEN" ]; then
  changes
  echo "==> next: decide from the changes above what the push carries and the wording, then run .agents/skills/create-pr/scripts/regenerate.sh; the push updates this PR, so do not open another" >&2
else
  git fetch origin "$base" >&2
  echo "==> next: git switch -c <new-branch> origin/$base (uncommitted changes come along), then commit there" >&2
fi
