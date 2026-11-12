#!/bin/sh
# Usage: references.sh <file>   (a plot file, or the story file itself)
# Prints the path of each `- @<path>` under the plot's ## References, one per
# line: the source's, or for a story file the plot paired with it as write and
# draft map it: plot/<x>.md -> ../<leading number of x, else x>.txt.
set -eu
[ $# -eq 1 ] || { echo "usage: references.sh <file>" >&2; exit 2; }
. "$(dirname -- "$0")/local-path.sh"
f=$(local_path "$1")
[ -f "$f" ] || { echo "references: no such file: $f" >&2; exit 1; }
refs() {
  awk '/^## / { on = ($0 == "## References"); next } on && sub(/^- @/, "")' "$1"
}
case $f in
  *.txt)
    stem=$(basename -- "$f" .txt)
    for md in "$(dirname -- "$f")"/plot/*.md; do
      [ -f "$md" ] || continue
      k=$(basename -- "$md" .md)
      n=$(printf '%s' "$k" | sed -n 's/^\([0-9][0-9]*\).*/\1/p')
      if [ "${n:-$k}" = "$stem" ]; then refs "$md"; fi
    done ;;
  *) refs "$f" ;;
esac
