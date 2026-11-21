#!/bin/sh
# Usage: layout.sh <slug> [campaign|competitive]
# Prints the engine, the layout file path, the map's mode and the layout steps for that mode.
# The mode comes from the argument, else from the layout file's "mode"; with neither, it
# prints the step that settles the mode.
set -eu
[ -f .agents/refs/engine.sh ] || { echo "layout: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
[ $# -ge 1 ] && [ $# -le 2 ] || { echo "usage: layout.sh <slug> [campaign|competitive]" >&2; exit 2; }
printf '%s' "$1" | grep -Eq '^[a-z][a-z0-9]*(-[a-z0-9]+)*$' || { echo "layout: slug must be kebab-case: $1" >&2; exit 1; }
out="docs/design/maps/$1.json"
self=$(dirname -- "$0")
mode=${2:-}
[ -n "$mode" ] || [ ! -f "$out" ] || mode=$(jq -r '.mode // empty' "$out")
case $mode in
  campaign | competitive) ;;
  "") prompt mode self="$self" slug="$1"; exit 0 ;;
  *) echo "layout: mode must be campaign or competitive: $mode" >&2; exit 1 ;;
esac
printf 'engine\t%s\n' "$(engine_name)"
printf 'layout\t%s\n' "$out"
printf 'mode\t%s\n' "$mode"
if [ -f "$out" ]; then
  prompt edit layout="$out" mode="$mode"
else
  prompt new mode="$mode"
fi
prompt "layout-$mode"
prompt next self="$self" slug="$1"
