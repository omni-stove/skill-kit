#!/bin/sh
# Usage: source.sh <file>   (a plot file, or the story file itself)
# Prints the source as a `Source:` line, the output file it is written to, and the
# action to take on that output. Output, from where the source sits: plot/<x>.md ->
# ../<leading number of x, else x>.txt; plot.md -> index.txt beside it; another
# .md -> <stem>.txt beside it; a .txt is the output itself and is revised in place.
set -eu
[ $# -eq 1 ] || { echo "usage: source.sh <file>" >&2; exit 2; }
f=$1
[ -f "$f" ] || { echo "source: no such file: $f" >&2; exit 1; }
dir=$(dirname -- "$f")
stem=$(basename -- "$f")
stem=${stem%.*}
case $f in
  *.txt)
    echo "Output: $f"
    echo "The output file is the input. Read it and revise it as the user says."
    exit 0 ;;
esac
case $(basename -- "$dir") in
  plot)
    num=$(printf '%s' "$stem" | sed -n 's/^\([0-9][0-9]*\).*/\1/p')
    out="$(dirname -- "$dir")/${num:-$stem}.txt" ;;
  *)
    [ "$stem" = plot ] && stem=index
    out="$dir/$stem.txt" ;;
esac
out=${out#./}
echo "Source: $f"
echo "Output: $out"
if [ -f "$out" ]; then
  echo "The output file exists. Read it, ask \"Continue from where you left off, or start over?\", and wait for the response."
else
  echo "The output file does not exist yet. Start from the first Scene."
fi
