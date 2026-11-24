#!/bin/sh
# Usage: profile.sh <slug>
# Prints the engine facts, the map's layout file and the performance budget, then the step that
# writes the budget if there is none and the one that samples the map.
set -eu
[ -f .agents/refs/engine.sh ] || { echo "profile: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
[ $# -eq 1 ] || { echo "usage: profile.sh <slug>" >&2; exit 2; }
layout="docs/design/maps/$1.json"
budget=docs/design/perf.json
[ -f "$layout" ] || { echo "profile: $layout not found — lay the map out first, then rerun." >&2; exit 1; }
printf 'engine\t%s\n' "$(engine_name)"
printf 'source_root\t%s\n' "$(source_root)"
printf 'layout\t%s\n' "$layout"
printf 'budget\t%s\n' "$budget"
printf 'build\t%s\n' "$(build_cmd)"
printf 'headless\t%s\n' "$(headless_cmd)"
printf 'log\t%s\n' "$(runtime_log)"
[ -f "$budget" ] || prompt budget budget="$budget"
prompt sample source_root="$(source_root)" layout="$layout" log="$(runtime_log)" self="$(dirname -- "$0")" slug="$1"
