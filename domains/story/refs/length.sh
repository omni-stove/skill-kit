#!/bin/sh
# Usage: length.sh <plot file> <story file> [<first>-<last>]...
# Takes one line range of the story file per event with a length under the plot's
# ## 分量, in order, and prints `<event>: <counted>/<minimum><unit>` for each event
# under its minimum; prints nothing when none is. 字 counts characters other than
# whitespace; words counts whitespace-separated words. Counts bytes under LC_ALL=C,
# so any locale gives the same result.
set -eu
[ $# -ge 2 ] || { echo "usage: length.sh <plot file> <story file> [<first>-<last>]..." >&2; exit 2; }
. "$(dirname -- "$0")/local-path.sh"
plot=$(local_path "$1")
f=$(local_path "$2")
shift 2
[ -f "$plot" ] || { echo "length: no such file: $plot" >&2; exit 1; }
[ -f "$f" ] || { echo "length: no such file: $f; save the text there and run this again" >&2; exit 1; }
events=$(awk '
/^## / { on = ($0 == "## 分量"); next }
on && /^- / && match($0, /: *[0-9]+ *(字|words?) *$/) {
  name = substr($0, 3, RSTART - 3)
  tail = substr($0, RSTART + 1)
  gsub(/ /, "", tail)
  min = tail
  sub(/[^0-9].*/, "", min)
  printf "%s\t%s\t%s\n", name, min, (tail ~ /字$/ ? "字" : " words")
}' "$plot")
n=0
[ -z "$events" ] || n=$(printf '%s\n' "$events" | wc -l | tr -d ' ')
[ "$n" -eq $# ] || { echo "length: $plot lists $n event(s) with a length under 分量 but $# line range(s) were given; give one <first>-<last> per event, in order, and run this again" >&2; exit 1; }
[ "$n" -gt 0 ] || exit 0
total=$(awk 'END { print NR }' "$f")
tab=$(printf '\t')
while IFS=$tab read -r name min unit; do
  bad="length: '$1' is not a line range of $f, which has $total lines; give the event's lines as <first>-<last> and run this again"
  case $1 in
    *[!0-9-]* | -* | *- | *-*-*) echo "$bad" >&2; exit 1 ;;
    *-*) ;;
    *) echo "$bad" >&2; exit 1 ;;
  esac
  first=${1%-*}
  last=${1#*-}
  { [ "$first" -ge 1 ] && [ "$first" -le "$last" ] && [ "$last" -le "$total" ]; } || { echo "$bad" >&2; exit 1; }
  shift
  range=$(LC_ALL=C sed -n "${first},${last}p" "$f")
  if [ "$unit" = "字" ]; then
    count=$(printf '%s' "$range" | LC_ALL=C sed 's/　//g' | LC_ALL=C tr -d ' \t\r\n' | LC_ALL=C tr -d '\200-\277' | wc -c | tr -d ' ')
  else
    count=$(printf '%s' "$range" | LC_ALL=C wc -w | tr -d ' ')
  fi
  [ "$count" -ge "$min" ] || printf '%s: %s/%s%s\n' "$name" "$count" "$min" "$unit"
done <<EOF
$events
EOF
