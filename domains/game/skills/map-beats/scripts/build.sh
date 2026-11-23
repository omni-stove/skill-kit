#!/bin/sh
# Usage: build.sh <slug>
# Prints the engine facts the greybox build needs, then the step that builds the layout with
# its beats.
set -eu
[ -f .agents/refs/engine.sh ] || { echo "build: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
[ $# -eq 1 ] || { echo "usage: build.sh <slug>" >&2; exit 2; }
layout="docs/design/maps/$1.json"
[ -f "$layout" ] || { echo "build: $layout not found — run beats.sh $1 first." >&2; exit 1; }
printf 'engine\t%s\n' "$(engine_name)"
printf 'layout\t%s\n' "$layout"
printf 'source_root\t%s\n' "$(source_root)"
printf 'headless\t%s\n' "$(headless_cmd)"
printf 'log\t%s\n' "$(runtime_log)"
prompt build layout="$layout" source_root="$(source_root)"
