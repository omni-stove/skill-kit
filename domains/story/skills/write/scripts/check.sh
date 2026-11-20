#!/bin/sh
# Usage: check.sh <source file> <output file> [<report file>]
# Fixes the output file's format through format.sh, prints the checks the harness
# runs over the whole file and the narration lines ending on だった。, then the
# hand-off to reply with.
set -eu
[ $# -eq 2 ] || [ $# -eq 3 ] || { echo "usage: check.sh <source file> <output file> [<report file>]" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
src=$(local_path "$1")
f=$(local_path "$2")
report=${3:-}
[ -f "$src" ] || { echo "check: no such file: $src" >&2; exit 1; }
[ -f "$f" ] || { echo "check: no such file: $f" >&2; exit 1; }
[ -z "$report" ] || [ -f "$report" ] || { echo "check: no such file: $report" >&2; exit 1; }
format=.agents/refs/format.sh
[ -f "$format" ] || format=$(dirname -- "$0")/../../../refs/format.sh
sh "$format" --guard "$f" > /dev/null
prompt checks-local
datta=$(grep -n 'だった。' "$f" | grep -vE '^[0-9]+:(「|『)' || true)
if [ -n "$datta" ]; then
  prompt datta
  printf '%s\n' "$datta"
fi
prompt check-hand-off
