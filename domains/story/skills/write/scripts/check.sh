#!/bin/sh
# Usage: check.sh <source file> <output file> [<report file>]
# Prints the guards and author-rules.md (when it exists) to fix the output file by,
# the checks guard-scan's scan.sh --all gives for it, then the hand-off to reply with,
# which runs check.sh again on the same arguments after each revision.
set -eu
[ $# -eq 2 ] || [ $# -eq 3 ] || { echo "usage: check.sh <source file> <output file> [<report file>]" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
src=$(local_path "$1")
f=$(local_path "$2")
[ -f "$src" ] || { echo "check: no such file: $src" >&2; exit 1; }
[ -f "$f" ] || { echo "check: no such file: $f" >&2; exit 1; }
[ $# -eq 2 ] || [ -f "$3" ] || { echo "check: no such file: $3" >&2; exit 1; }
cat .agents/refs/japanese-web-novel-sentence-guard.md
cat .agents/refs/japanese-web-novel-narration-guard.md
[ ! -f author-rules.md ] || { cat .agents/refs/author-override.md; cat author-rules.md; }
echo
sh "$(dirname -- "$0")/../../../refs/guard-scan/scripts/scan.sh" --all "$f"
args="\"$src\" \"$f\""
[ $# -eq 2 ] || args="$args \"$3\""
prompt hand-off again="$0 $args"
