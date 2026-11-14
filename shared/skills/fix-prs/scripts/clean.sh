#!/usr/bin/env bash
# Remove each worktree scan.sh added under <git common dir>/fix-prs/ that holds nothing left to
# push: no change, no merge in progress and no commit ahead of its upstream. Print one line per
# worktree kept as unpushed<TAB><number><TAB><worktree>, then what to do next.
# usage: clean.sh
set -euo pipefail
. "$(dirname -- "$0")/../../../refs/prompt.sh"

[ $# -eq 0 ] || { echo "usage: clean.sh" >&2; exit 2; }
common="$(git rev-parse --path-format=absolute --git-common-dir)"

for dir in "$common"/fix-prs/*/; do
  [ -d "$dir" ] || continue
  dir="${dir%/}"
  [ -L "$dir/.agents" ] && rm "$dir/.agents"
  ahead=0
  if git -C "$dir" symbolic-ref -q HEAD >/dev/null; then
    ahead="$(git -C "$dir" rev-list --count '@{u}..HEAD' 2>/dev/null || echo unknown)"
  fi
  if [ -z "$(git -C "$dir" status --porcelain)" ] \
    && ! git -C "$dir" rev-parse -q --verify MERGE_HEAD >/dev/null \
    && [ "$ahead" = 0 ]; then
    git worktree remove "$dir"
  else
    ln -s "$(git rev-parse --show-toplevel)/.agents" "$dir/.agents" 2>/dev/null || true
    printf 'unpushed\t%s\t%s\n' "$(basename -- "$dir")" "$dir"
  fi
done
git worktree prune
prompt clean >&2
