#!/bin/sh
# Usage: objectives.sh <slug>
# Prints the engine, the source root, the competitive map's layout file and its objective file,
# then the step that writes or edits the objectives and the view step.
set -eu
[ -f .agents/refs/engine.sh ] || { echo "objectives: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
[ $# -eq 1 ] || { echo "usage: objectives.sh <slug>" >&2; exit 2; }
printf '%s' "$1" | grep -Eq '^[a-z][a-z0-9]*(-[a-z0-9]+)*$' || { echo "objectives: slug must be kebab-case: $1" >&2; exit 1; }
layout="docs/design/maps/$1.json"
out="docs/design/objectives/$1.json"
[ -f "$layout" ] || { echo "objectives: $layout not found — lay the map out first, then rerun." >&2; exit 1; }
mode=$(jq -r '.mode // empty' "$layout")
[ "$mode" = competitive ] || { echo "objectives: $layout is not a competitive map (mode: ${mode:-none}) — tell the user objectives are for competitive maps, then stop." >&2; exit 1; }
printf 'engine\t%s\n' "$(engine_name)"
printf 'source_root\t%s\n' "$(source_root)"
printf 'layout\t%s\n' "$layout"
printf 'objectives\t%s\n' "$out"
if [ -f "$out" ]; then
  prompt edit objectives="$out" layout="$layout"
else
  prompt new objectives="$out" layout="$layout" source_root="$(source_root)"
fi
prompt next self="$(dirname -- "$0")" slug="$1"
