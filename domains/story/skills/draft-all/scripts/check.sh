#!/bin/sh
# Usage: check.sh <plot file> <output file> <notes file>
# Run by each drafting Agent once its output is saved: fixes the output's format through
# format.sh and prints the lines it finds against the format rules, then says when the
# output is shorter than the plot's ## Length, then prints the step to save the notes.
set -eu
[ $# -eq 3 ] || { echo "usage: check.sh <plot file> <output file> <notes file>" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
src=$(local_path "$1")
f=$(local_path "$2")
notes=$3
[ -f "$src" ] || { echo "check: no such file: $src" >&2; exit 1; }
[ -f "$f" ] || { echo "check: no such file: $f; save the draft there and run this again" >&2; exit 1; }
format=.agents/refs/format.sh
[ -f "$format" ] || format=$(dirname -- "$0")/../../../refs/format.sh
fmt=$(sh "$format" "$f")
if [ -n "$fmt" ]; then
  prompt format
  printf '%s\n\n' "$fmt"
fi
short=$(sh "$(dirname -- "$0")/../../../refs/length.sh" "$src" "$f")
if [ -n "$short" ]; then
  prompt short
  printf '%s\n\n' "$short"
fi
prompt notes file="$src" notes="$notes"
