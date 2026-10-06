#!/bin/sh
# Usage: next.sh <file>
# Prints the next unprocessed .txt file in <file>'s directory with its line
# count and the action to take on it — natural sort, synopsis and dotfiles
# excluded. A fresh run empties this directory's record,
# out/read-through/<dir key>.impressions.md, so only the latest run's
# impressions are kept. When every file is processed, prints
# ALL_DONE with the closing action, and clears the progress record so the next
# run starts fresh.
here=$(dirname "$0")
. "$here/../../../refs/local-path.sh"
set -- "$(local_path "$1")"
dir=$(cd "$(dirname "$1")" && pwd)
key=$(echo "$dir" | tr '/' '_')
state="out/read-through/$key.state"
record="out/read-through/$key.impressions.md"
last="out/read-through/$key.last"
mkdir -p out/read-through
touch "$state"
# fresh run: discard the previous run's impressions
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
with your impression of it, written applying the loaded rules, on stdin.
EOF
else
  rm -f "$state" "$last"
  cat <<EOF
ALL_DONE
Run $here/summary.sh "$1" with an overall summary, written without restating
the per-file impressions, on stdin.
EOF
fi
