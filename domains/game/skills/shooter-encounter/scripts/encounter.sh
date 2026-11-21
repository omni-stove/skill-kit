#!/bin/sh
# Usage: encounter.sh <slug>
# Prints the engine, the source root, the campaign map's layout file and its encounter file,
# then the step that writes or edits the encounters.
set -eu
[ -f .agents/refs/engine.sh ] || { echo "encounter: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
[ $# -eq 1 ] || { echo "usage: encounter.sh <slug>" >&2; exit 2; }
printf '%s' "$1" | grep -Eq '^[a-z][a-z0-9]*(-[a-z0-9]+)*$' || { echo "encounter: slug must be kebab-case: $1" >&2; exit 1; }
layout="docs/design/maps/$1.json"
out="docs/design/encounters/$1.json"
[ -f "$layout" ] || { echo "encounter: $layout not found — lay the map out first, then rerun." >&2; exit 1; }
mode=$(jq -r '.mode // empty' "$layout")
[ "$mode" = campaign ] || { echo "encounter: $layout is not a campaign map (mode: ${mode:-none}) — tell the user encounters go on a campaign route, then stop." >&2; exit 1; }
printf 'engine\t%s\n' "$(engine_name)"
printf 'source_root\t%s\n' "$(source_root)"
printf 'layout\t%s\n' "$layout"
printf 'encounters\t%s\n' "$out"
if [ -f "$out" ]; then
  prompt edit encounters="$out" layout="$layout"
else
  prompt new encounters="$out" layout="$layout" source_root="$(source_root)"
fi
prompt next self="$(dirname -- "$0")" slug="$1"
