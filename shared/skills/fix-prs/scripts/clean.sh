#!/usr/bin/env bash
# Remove each worktree scan.sh added under <main checkout>-fix-prs/ that holds nothing left to
# push: no change, no merge in progress and no commit ahead of its upstream, then that directory
# once it is empty. Print one line per worktree kept as unpushed<TAB><number><TAB><worktree>,
# then what to do next.
# usage: clean.sh
set -euo pipefail
. "$(dirname -- "$0")/../../../refs/prompt.sh"

[ $# -eq 0 ] || { echo "usage: clean.sh" >&2; exit 2; }
# Beside the main checkout, not under .git/, where a repo's tools skip the files or fail on them
trees="$(git worktree list --porcelain | sed -n '1s/^worktree //p')-fix-prs"

for dir in "$trees"/*/; do
  [ -d "$dir" ] || continue
  dir="${dir%/}"
  ahead=0
  if git -C "$dir" symbolic-ref -q HEAD >/dev/null; then
    ahead="$(git -C "$dir" rev-list --count '@{u}..HEAD' 2>/dev/null || echo unknown)"
  fi
  if [ -z "$(git -C "$dir" status --porcelain)" ] \
    && ! git -C "$dir" rev-parse -q --verify MERGE_HEAD >/dev/null \
    && [ "$ahead" = 0 ]; then
    git worktree remove "$dir"
  else
    printf 'unpushed\t%s\t%s\n' "$(basename -- "$dir")" "$dir"
  fi
done
git worktree prune
rmdir "$trees" 2>/dev/null || true
prompt clean >&2
