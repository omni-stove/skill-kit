#!/bin/sh
# Usage: playtest.sh <slug>
# Prints the engine facts, the map's layout file and its encounter or spawn file where there is
# one, then the step that has the game log the [Play] lines and the play check.
set -eu
[ -f .agents/refs/engine.sh ] || { echo "playtest: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
[ $# -eq 1 ] || { echo "usage: playtest.sh <slug>" >&2; exit 2; }
layout="docs/design/maps/$1.json"
[ -f "$layout" ] || { echo "playtest: $layout not found — lay the map out first, then rerun." >&2; exit 1; }
ctrl=$(control_mcp)
printf 'engine\t%s\n' "$(engine_name)"
printf 'source_root\t%s\n' "$(source_root)"
printf 'layout\t%s\n' "$layout"
for f in "docs/design/encounters/$1.json" "docs/design/spawns/$1.json" "docs/design/objectives/$1.json"; do
  [ ! -f "$f" ] || printf 'design\t%s\n' "$f"
done
printf 'log\t%s\n' "$(runtime_log)"
printf 'ctrl\t%s\n' "$ctrl"
prompt log source_root="$(source_root)"
case $ctrl in
  *computer*) prompt play-gui ctrl="$ctrl" self="$(dirname -- "$0")" slug="$1" ;;
  *) prompt play-log self="$(dirname -- "$0")" slug="$1" ;;
esac
