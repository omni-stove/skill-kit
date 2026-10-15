#!/bin/sh
# Usage: source.sh <file>   (a plot file, or the story file itself)
# Prints the output file the source is written to and the steps to write a Scene into it.
# Output, from where the source sits: plot/<x>.md -> ../<leading number of x,
# else x>.txt; plot.md -> index.txt beside it; another .md -> <stem>.txt beside
# it; a .txt is the output itself and is revised in place.
set -eu
[ $# -eq 1 ] || { echo "usage: source.sh <file>" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
set -- "$(local_path "$1")"
f=$1
[ -f "$f" ] || { echo "source: no such file: $f" >&2; exit 1; }
dir=$(dirname -- "$f")
stem=$(basename -- "$f")
stem=${stem%.*}
case $f in
  *.txt)
    echo "Output: $f"
    echo "The output file is the input. Read it and revise it as the user says, by the loaded rules."
    echo "Save it, then run $(dirname -- "$0")/scene-check.sh \"$f\""
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
echo "Output: $out"
if [ -f "$out" ]; then
  echo "The output file exists. Read it, ask \"Continue from where you left off, or start over?\", and wait for the response."
else
  echo "The output file does not exist yet. Start from the first Scene."
fi
cat <<NEXT
Launch one Agent on the source file to report what it must stay consistent with and what
of it the reader already has; the Agent runs $(dirname -- "$0")/others.sh "$f".
Write 1 Scene by the loaded rules: the source file leads, open another file only for a
fact the report lacks, and deliver its プロットの意図 through events alone. Save the Scene
to the output file, then run $(dirname -- "$0")/scene-check.sh "$out"
NEXT
