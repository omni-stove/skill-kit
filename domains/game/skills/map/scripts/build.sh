#!/bin/sh
# Usage: build.sh <slug>
# Prints the engine facts the greybox build needs and the build, walk-check and art steps.
set -eu
[ -f .agents/refs/engine.sh ] || { echo "build: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
[ $# -eq 1 ] || { echo "usage: build.sh <slug>" >&2; exit 2; }
out="docs/design/maps/$1.json"
[ -f "$out" ] || { echo "build: $out not found — run layout.sh $1 and write the layout first." >&2; exit 1; }
ctrl=$(control_mcp)
printf 'engine\t%s\n' "$(engine_name)"
printf 'layout\t%s\n' "$out"
printf 'source_root\t%s\n' "$(source_root)"
printf 'headless\t%s\n' "$(headless_cmd)"
printf 'log\t%s\n' "$(runtime_log)"
printf 'ctrl\t%s\n' "$ctrl"
prompt build layout="$out" source_root="$(source_root)"
case $ctrl in
  *computer*) prompt walk-gui ctrl="$ctrl" ;;
  *) prompt walk-log ;;
esac
prompt art
