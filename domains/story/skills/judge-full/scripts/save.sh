#!/bin/sh
# Usage: save.sh <manuscript-path> <first-round|discussion-<n>|report> < report
# Writes the report read from stdin to
# out/judge-full/<manuscript name>-<label>-<epoch>.md, prints the path written, and the
# round that follows.
[ $# -eq 2 ] || { echo "usage: save.sh <manuscript-path> <first-round|discussion-<n>|report>  (report on stdin)" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
set -- "$(local_path "$1")" "$2"
base=$(basename "$1")
mkdir -p out/judge-full
path="out/judge-full/${base%.*}-$2-$(date +%s).md"
cat > "$path"
printf '%s\n' "$path"
final() {
  cat <<FINAL
Otherwise output the final vote count (N/M) with the overall verdict — 大賞 when more than
half the judges vote 大賞, otherwise 大賞ではない — each judge's label and final verdict in
one line noting any change, what the discussion settled, and what stayed split, and run
$0 "$1" report with that output.
FINAL
}
case $2 in
  first-round) n=1 ;;
  discussion-*) n=$(( ${2#discussion-} + 1 )) ;;
  *) exit 0 ;;
esac
cat <<NEXT
If a verdict or a point is still split$([ "$n" -gt 1 ] && printf ' and a verdict changed this round'), run a discussion round: send each judge, via
SendMessage, the other judges' verdicts and reasoning on the split points, attributed by
label only, never by model, with the task to rebut or concede each point and restate
their verdict — changing it is allowed. Output the verdicts and what moved, and run
$0 "$1" discussion-$n with each judge's statement, verbatim.
NEXT
final "$1"
