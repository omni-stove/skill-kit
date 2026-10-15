#!/bin/sh
# Usage: save.sh <manuscript-path> <first-round|discussion-<n>|report> < report
# Writes the report read from stdin to
# out/judge-full/<manuscript name>-<label>-<epoch>.md, prints the path written, and the
# round that follows.
[ $# -eq 2 ] || { echo "usage: save.sh <manuscript-path> <first-round|discussion-<n>|report>  (report on stdin)" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
set -- "$(local_path "$1")" "$2"
base=$(basename "$1")
mkdir -p out/judge-full
path="out/judge-full/${base%.*}-$2-$(date +%s).md"
cat > "$path"
printf '%s\n' "$path"
case $2 in
  first-round) n=1 ;;
  discussion-*) n=$(( ${2#discussion-} + 1 )) ;;
  *) exit 0 ;;
esac
changed=
[ "$n" -gt 1 ] && changed=' and a verdict changed this round'
prompt discussion changed="$changed" self="$0" manuscript="$1" n="$n"
prompt final self="$0" manuscript="$1"
