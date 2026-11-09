#!/bin/sh
# Usage: length.sh <plot file> <story file>
# Prints `<counted>/<length>` when the story file is shorter than the length under the
# plot's ## Length; prints nothing otherwise. 字 counts characters other than whitespace;
# words counts whitespace-separated words. Counts bytes under LC_ALL=C, so any locale
# gives the same result.
set -eu
[ $# -eq 2 ] || { echo "usage: length.sh <plot file> <story file>" >&2; exit 2; }
. "$(dirname -- "$0")/local-path.sh"
plot=$(local_path "$1")
f=$(local_path "$2")
[ -f "$plot" ] || { echo "length: no such file: $plot" >&2; exit 1; }
[ -f "$f" ] || { echo "length: no such file: $f; save the text there and run this again" >&2; exit 1; }
length=$(awk '/^## / { on = ($0 == "## Length"); next } on && /^[0-9]+ *(字|words?) *$/ { print; exit }' "$plot")
[ -n "$length" ] || exit 0
case $length in
  *字*) count=$(LC_ALL=C sed 's/　//g' "$f" | LC_ALL=C tr -d ' \t\r\n' | LC_ALL=C tr -d '\200-\277' | wc -c | tr -d ' ') ;;
  *) count=$(LC_ALL=C wc -w < "$f" | tr -d ' ') ;;
esac
[ "$count" -ge "${length%%[!0-9]*}" ] || printf '%s/%s\n' "$count" "$length"
