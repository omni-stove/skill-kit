#!/bin/sh
# Usage: beats.sh <slug>
# Prints the map's layout file, its mode, and a section line per id prefix of its pieces, in
# the order the pieces list them, with the name of the section's beat or - for none. Then
# prints the step that writes the beats.
set -eu
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
[ $# -eq 1 ] || { echo "usage: beats.sh <slug>" >&2; exit 2; }
printf '%s' "$1" | grep -Eq '^[a-z][a-z0-9]*(-[a-z0-9]+)*$' || { echo "beats: slug must be kebab-case: $1" >&2; exit 1; }
command -v jq >/dev/null || { echo "beats: jq not found — install jq, then rerun." >&2; exit 1; }
layout="docs/design/maps/$1.json"
[ -f "$layout" ] || { echo "beats: $layout not found — lay the map out first, then rerun." >&2; exit 1; }
jq -e '.pieces | type == "array" and length > 0' "$layout" >/dev/null \
  || { echo "beats: $layout has no pieces — lay the map out first, then rerun." >&2; exit 1; }
printf 'layout\t%s\n' "$layout"
printf 'mode\t%s\n' "$(jq -r '.mode // "none"' "$layout")"
jq -r '
([(.beats // [])[] | {key: (.id // "" | tostring), value: (.name // "" | tostring)}] | from_entries) as $b
| reduce (.pieces[] | .id // "" | tostring | split("-")[0]) as $s ([]; if index([$s]) then . else . + [$s] end)
| .[] | "section\t\(.)\t\($b[.] // "-")"
' "$layout"
prompt write layout="$layout"
prompt next self="$(dirname -- "$0")" slug="$1"
