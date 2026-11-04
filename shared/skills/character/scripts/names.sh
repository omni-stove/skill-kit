#!/usr/bin/env bash
# Print, for each name, the lines in this repo that already use it — tracked and untracked
# files alike, outside the synced kit — then the judgment to make on them.
# usage: names.sh <name>...
set -euo pipefail
. "$(dirname -- "$0")/../../../refs/prompt.sh"

[ "$#" -ge 1 ] || { echo "usage: names.sh <name>..." >&2; exit 2; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || { echo "names.sh: not in a git repo; run it from the story repo's root" >&2; exit 2; }

max=20
for name in "$@"; do
  hits="$(git grep -n -I -F --untracked -e "$name" -- . ':!.agents' ':!.claude' 2>/dev/null || true)"
  if [ -z "$hits" ]; then
    printf '==> %s: none\n' "$name"
    continue
  fi
  count="$(printf '%s\n' "$hits" | wc -l | tr -d ' ')"
  printf '==> %s: %s\n' "$name" "$count"
  printf '%s\n' "$hits" | head -n "$max"
  [ "$count" -le "$max" ] || printf '... %s more\n' "$((count - max))"
done
prompt names >&2
