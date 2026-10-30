#!/bin/sh
# Usage: scene-check.sh <source file> <output file> [<report file>]
# Fixes the output file's format through format.sh, then prints the checks to run
# over the file before each hand-off, the narration lines with a negative sentence
# ending (ない。, なかった。), the lines format.sh finds against the format rules,
# and the hand-off to reply with, which runs check.sh on the same arguments once
# the source has no Scene left.
set -eu
[ $# -eq 2 ] || [ $# -eq 3 ] || { echo "usage: scene-check.sh <source file> <output file> [<report file>]" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
src=$(local_path "$1")
f=$(local_path "$2")
[ -f "$src" ] || { echo "scene-check: no such file: $src" >&2; exit 1; }
[ -f "$f" ] || { echo "scene-check: no such file: $f" >&2; exit 1; }
format=.agents/refs/format.sh
[ -f "$format" ] || format=$(dirname -- "$0")/../../../refs/format.sh
fmt=$(sh "$format" "$f")
prompt checks
neg=$(grep -nE '(ない|なかった)。' "$f" | grep -vE '^[0-9]+:[「『]' || true)
if [ -n "$neg" ]; then
  prompt negative
  printf '%s\n' "$neg"
fi
if [ -n "$fmt" ]; then
  prompt format
  printf '%s\n' "$fmt"
fi
check="$(dirname -- "$0")/check.sh \"$src\" \"$f\""
[ $# -eq 2 ] || check="$check \"$3\""
prompt hand-off check="$check"
