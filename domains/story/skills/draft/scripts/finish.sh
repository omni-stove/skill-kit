#!/bin/sh
# Usage: finish.sh <plot file> <output file>
# Fixes the output file's format through format.sh, prints the lines it finds
# against the format rules, then the feedback to reply with.
set -eu
[ $# -eq 2 ] || { echo "usage: finish.sh <plot file> <output file>" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
src=$(local_path "$1")
f=$(local_path "$2")
[ -f "$src" ] || { echo "finish: no such file: $src" >&2; exit 1; }
[ -f "$f" ] || { echo "finish: no such file: $f; save the draft there and run this again" >&2; exit 1; }
format=.agents/refs/format.sh
[ -f "$format" ] || format=$(dirname -- "$0")/../../../refs/format.sh
fmt=$(sh "$format" "$f")
if [ -n "$fmt" ]; then
  prompt format
  printf '%s\n' "$fmt"
fi
prompt feedback file="$src" out="$f"
