#!/bin/sh
# Usage: view.sh <slug>
# Draws docs/design/maps/<slug>.json with its objectives as docs/design/maps/<slug>.svg. Prints a
# warn line per objective without an id or with a repeated one, per defending team no spawn
# starts, and for a map without objectives, then the SVG path and the review and measure step.
set -eu
[ -f .agents/refs/engine.sh ] || { echo "view: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
[ $# -eq 1 ] || { echo "usage: view.sh <slug>" >&2; exit 2; }
layout="docs/design/maps/$1.json"
out=$(sh "$(dirname -- "$0")/../../../refs/map-view.sh" "$1")
jq -r '
[(.spawns // [])[] | select((.use // "start") == "start") | .team // "" | tostring] as $teams
| (.objectives // []) as $os
| (if $os | length == 0 then "warn\t-\tno objectives" else empty end),
  ($os[] | (.id // "" | tostring) as $i
   | (if $i == "" then "warn\t-\tan objective at \(.pos | tostring) has no id" else empty end),
     (.team // "" | tostring) as $t
   | (if $t != "" and ($teams | index([$t]) | not) then "warn\t\($i)\tno start spawn of team \($t)" else empty end)),
  ([$os[] | .id // empty | tostring] | group_by(.)[] | select(length > 1) | "warn\t\(.[0])\tid used \(length) times")
' "$layout"
printf '%s\n' "$out"
prompt view layout="$layout" svg="${out#svg	}" source_root="$(source_root)" log="$(runtime_log)" self="$(dirname -- "$0")" slug="$1"
