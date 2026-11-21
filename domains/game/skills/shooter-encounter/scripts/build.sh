#!/bin/sh
# Usage: build.sh <slug>
# Prints the engine facts the encounter build needs, then the build and play-check steps.
set -eu
[ -f .agents/refs/engine.sh ] || { echo "build: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
[ $# -eq 1 ] || { echo "usage: build.sh <slug>" >&2; exit 2; }
layout="docs/design/maps/$1.json"
enc="docs/design/encounters/$1.json"
[ -f "$enc" ] || { echo "build: $enc not found — run encounter.sh $1 and write the encounters first." >&2; exit 1; }
ctrl=$(control_mcp)
printf 'engine\t%s\n' "$(engine_name)"
printf 'layout\t%s\n' "$layout"
printf 'encounters\t%s\n' "$enc"
printf 'source_root\t%s\n' "$(source_root)"
printf 'headless\t%s\n' "$(headless_cmd)"
printf 'log\t%s\n' "$(runtime_log)"
printf 'ctrl\t%s\n' "$ctrl"
prompt build layout="$layout" source_root="$(source_root)"
case $ctrl in
  *computer*) prompt play-gui ctrl="$ctrl" ;;
  *) prompt play-log ;;
esac
