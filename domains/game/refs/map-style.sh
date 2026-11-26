#!/bin/sh
# Usage: map-style.sh [layout.json...]
# Keeps docs/design/map-style.json, the colour and legend label of everything the repo's map
# figures draw: writes it from the kit's map-style.json when missing, adds the kit's keys it
# lacks, and gives each spawn team of the layouts that it lacks the first unused palette colour.
# Prints the file's path.
set -eu
command -v jq >/dev/null || { echo "map-style: jq not found — install jq, then rerun." >&2; exit 1; }
out=docs/design/map-style.json
mkdir -p docs/design
[ -f "$out" ] || printf '{}\n' > "$out"
jq -e . "$out" >/dev/null 2>&1 || { echo "map-style: $out is not valid JSON — fix it, then rerun." >&2; exit 1; }
teams='[]'
[ $# -eq 0 ] || teams=$(jq -s '[.[] | (.spawns // [])[] | .team // "" | tostring | select(. != "")] | unique' "$@")
new=$(jq --slurpfile d "$(dirname -- "$0")/map-style.json" --argjson teams "$teams" '
  reduce $teams[] as $t ($d[0] * .;
    if .teams[$t] then . else
      ([.palette[] as $c | select([.teams[].color] | index([$c]) | not) | $c] | first // "#999999") as $c
      | .teams[$t] = {color: $c, label: $t} end)' "$out")
[ "$new" = "$(jq . "$out")" ] || printf '%s\n' "$new" > "$out"
printf '%s\n' "$out"
