#!/bin/sh
# Usage: view.sh <slug>
# Draws docs/design/maps/<slug>.json as docs/design/maps/<slug>.svg with each beat named over
# its pieces. Prints a warn line per section without a beat, beat without pieces and beat
# without notes, then the SVG path and the review step.
set -eu
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
[ $# -eq 1 ] || { echo "usage: view.sh <slug>" >&2; exit 2; }
layout="docs/design/maps/$1.json"
out=$(sh "$(dirname -- "$0")/../../../refs/map-view.sh" "$1")
jq -r '
[.pieces[] | .id // "" | tostring | split("-")[0]] as $secs
| [(.beats // [])[] | .id // "" | tostring] as $ids
| ($secs | unique[] | select(. as $s | $ids | index([$s]) | not) | "warn\t\(.)\tno beat"),
  ((.beats // [])[] | (.id // "" | tostring) as $i
   | (if $secs | index([$i]) then empty else "warn\t\($i)\tno piece id starts with \($i)-" end),
     (if (.notes // []) | length > 0 then empty else "warn\t\($i)\tno notes" end))
' "$layout"
printf '%s\n' "$out"
prompt view layout="$layout" svg="${out#svg	}" self="$(dirname -- "$0")" slug="$1"
