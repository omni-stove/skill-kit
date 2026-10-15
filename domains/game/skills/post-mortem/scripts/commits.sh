#!/bin/sh
# Usage: commits.sh <slug> <since> [<until>]
# Prints the period's commits, the earlier post-mortems, the output path and the drafting steps.
set -eu
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
[ $# -ge 2 ] && [ $# -le 3 ] || { echo "usage: commits.sh <slug> <since> [<until>]" >&2; exit 2; }
printf '%s' "$1" | grep -Eq '^[a-z][a-z0-9]*(-[a-z0-9]+)*$' || { echo "commits: slug must be kebab-case: $1" >&2; exit 1; }
out="docs/design/post-mortems/$1.md"
echo "== commits =="
git log --date=short --format='%ad %s' --since="$2" ${3:+--until="$3"}
echo "== earlier post-mortems =="
for f in docs/design/post-mortems/*.md; do
  [ -f "$f" ] && [ "$f" != "$out" ] && echo "$f"
done
echo "Output: $out"
if [ -f "$out" ]; then
  prompt exists
else
  prompt draft
fi
