#!/bin/sh
# Usage: scene-check.sh <source file> <output file> [<report file>]
# Prints the checks guard-scan's scan.sh --scene gives for the output file, then the
# hand-off to reply with, which runs check.sh on the same arguments once
# the source has no Scene left, or on y when the source is the output file itself.
set -eu
[ $# -eq 2 ] || [ $# -eq 3 ] || { echo "usage: scene-check.sh <source file> <output file> [<report file>]" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
src=$(local_path "$1")
f=$(local_path "$2")
[ -f "$src" ] || { echo "scene-check: no such file: $src" >&2; exit 1; }
[ -f "$f" ] || { echo "scene-check: no such file: $f" >&2; exit 1; }
sh "$(dirname -- "$0")/../../../refs/guard-scan/scripts/scan.sh" --scene "$f"
args="\"$src\" \"$f\""
[ $# -eq 2 ] || args="$args \"$3\""
check="$(dirname -- "$0")/check.sh $args"
again="$0 $args"
if [ "$src" = "$f" ]; then
  prompt hand-off-revise check="$check" again="$again"
else
  prompt hand-off check="$check" again="$again"
fi
