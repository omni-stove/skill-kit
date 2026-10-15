#!/usr/bin/env bash
# Push the current branch, merging the upstream first when the remote is ahead, then say
# what follows: open.sh when the branch has no PR yet, the report when the push updated one.
# usage: push.sh
set -euo pipefail

[ "$#" -eq 0 ] || { echo "usage: push.sh" >&2; exit 2; }
branch="$(git rev-parse --abbrev-ref HEAD)"
# shellcheck source=/dev/null
source .agents/refs/push-with-merge.sh
push_with_merge -u origin "$branch"

url="$(gh pr view --json url -q .url 2>/dev/null || true)"
if [ -n "$url" ]; then
  echo "==> next: the push updated $url; report that URL and the change in one line" >&2
else
  cat >&2 <<'NEXT'
==> next: run .agents/skills/create-pr/scripts/open.sh "<title>" "<purpose, with refs / Closes #n>" "<approach>" "<verification>" "<review points>" [--base <branch>] [--label <name>]... — a multi-line section is one argument with real newlines ($'line 1\nline 2')
NEXT
fi
