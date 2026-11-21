#!/bin/sh
# Usage: spawns.sh <slug>
# Prints the engine facts, the competitive map's layout file and its spawn file, then the step
# that writes or edits the respawn points and the one that measures them.
set -eu
[ -f .agents/refs/engine.sh ] || { echo "spawns: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
[ $# -eq 1 ] || { echo "usage: spawns.sh <slug>" >&2; exit 2; }
printf '%s' "$1" | grep -Eq '^[a-z][a-z0-9]*(-[a-z0-9]+)*$' || { echo "spawns: slug must be kebab-case: $1" >&2; exit 1; }
layout="docs/design/maps/$1.json"
out="docs/design/spawns/$1.json"
[ -f "$layout" ] || { echo "spawns: $layout not found — lay the map out first, then rerun." >&2; exit 1; }
mode=$(jq -r '.mode // empty' "$layout")
[ "$mode" = competitive ] || { echo "spawns: $layout is not a competitive map (mode: ${mode:-none}) — tell the user respawn points are for competitive maps, then stop." >&2; exit 1; }
printf 'engine\t%s\n' "$(engine_name)"
printf 'source_root\t%s\n' "$(source_root)"
printf 'layout\t%s\n' "$layout"
printf 'spawns\t%s\n' "$out"
printf 'headless\t%s\n' "$(headless_cmd)"
printf 'log\t%s\n' "$(runtime_log)"
if [ -f "$out" ]; then
  prompt edit spawns="$out" layout="$layout"
else
  prompt new spawns="$out" layout="$layout" source_root="$(source_root)"
fi
prompt measure layout="$layout" source_root="$(source_root)" log="$(runtime_log)" self="$(dirname -- "$0")" slug="$1"
