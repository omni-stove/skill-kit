#!/bin/sh
# Usage: scene.sh <source file> <output file> <report file>
# Prints the step to write a Scene of the source into the output, once the
# Agent's report on the source is saved.
set -eu
[ $# -eq 3 ] || { echo "usage: scene.sh <source file> <output file> <report file>" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
f=$(local_path "$1")
out=$(local_path "$2")
report=$3
[ -f "$f" ] || { echo "scene: no such file: $f" >&2; exit 1; }
[ -s "$report" ] || { echo "scene: the report $report is missing or empty; wait for the Agent's report, save it there, and run this again" >&2; exit 1; }
prompt scene scene_check="$(dirname -- "$0")/scene-check.sh" file="$f" out="$out" report="$report"
