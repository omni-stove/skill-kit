#!/bin/sh
# Usage: next.sh <directory | file in it>
# Prints the next undigested .txt file in the directory with its line count and
# the action to take on it — natural sort, synopsis and dotfiles excluded. A
# fresh run empties this directory's record, out/digest-through/<dir key>.md,
# so only the latest run's digests are kept. When every file is digested,
# prints ALL_DONE with the closing action, and clears the progress record so
# the next run starts fresh.
set -eu
[ $# -eq 1 ] || { echo "usage: next.sh <directory | file>" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
set -- "$(local_path "$1")"
if [ -d "$1" ]; then dir=$(cd "$1" && pwd)
elif [ -f "$1" ]; then dir=$(cd "$(dirname -- "$1")" && pwd)
else echo "next: no such file or directory: $1" >&2; exit 1; fi
here=$(dirname "$0")
key=$(echo "$dir" | tr '/' '_')
state="out/digest-through/$key.state"
record="out/digest-through/$key.md"
mkdir -p out/digest-through
touch "$state"
# fresh run: discard the previous run's digests
[ -s "$state" ] || : > "$record"
next=$(find "$dir" -maxdepth 1 -type f -name '*.txt' ! -name 'synopsis*' ! -name '.*' | sort -V |
  while IFS= read -r f; do
    grep -Fxq "$(basename "$f")" "$state" || { printf '%s\n' "$f"; break; }
  done)
if [ -n "$next" ]; then
  wc -l "$next"
  cat <<EOF
Read that file whole into context — only that file. Then run
$here/done.sh "$next"
with its digest on stdin.
EOF
else
  rm -f "$state"
  cat <<EOF
ALL_DONE
Run $here/summary.sh "$dir" with an overall understanding of the directory on
stdin.
EOF
fi
