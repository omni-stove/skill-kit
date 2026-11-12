#!/bin/sh
# Usage: source.sh <file>   (a plot file, or the story file itself)
# Prints the output file the source is written to and the step to report on the
# source, which leads to scene.sh.
# Output, from where the source sits: plot/<x>.md -> ../<leading number of x,
# else x>.txt; plot.md -> index.txt beside it; another .md -> <stem>.txt beside
# it; a .txt is the output itself and is revised in place.
# Then prints a Reference line for each file references.sh gives.
set -eu
[ $# -eq 1 ] || { echo "usage: source.sh <file>" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
f=$(local_path "$1")
[ -f "$f" ] || { echo "source: no such file: $f" >&2; exit 1; }
dir=$(dirname -- "$f")
stem=$(basename -- "$f")
stem=${stem%.*}
others="$(dirname -- "$0")/../../../refs/others.sh"
refs() {
  sh "$(dirname -- "$0")/../../../refs/references.sh" "$f" | sed 's/^/Reference: /'
}
case $f in
  *.txt)
    echo "Output: $f"
    prompt scope others="$others" file="$f"
    refs
    prompt revise scene_check="$(dirname -- "$0")/scene-check.sh" file="$f"
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
[ ! -f "$out" ] || prompt exists
prompt scope others="$others" file="$f"
refs
prompt report file="$f" scene="$(dirname -- "$0")/scene.sh" out="$out"
