#!/bin/sh
# Usage: layout.sh <slug>
# Prints the engine, the layout file path and the layout steps.
set -eu
[ -f .agents/refs/engine.sh ] || { echo "layout: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
[ $# -eq 1 ] || { echo "usage: layout.sh <slug>" >&2; exit 2; }
printf '%s' "$1" | grep -Eq '^[a-z][a-z0-9]*(-[a-z0-9]+)*$' || { echo "layout: slug must be kebab-case: $1" >&2; exit 1; }
out="docs/design/maps/$1.json"
printf 'engine\t%s\n' "$(engine_name)"
printf 'layout\t%s\n' "$out"
if [ -f "$out" ]; then
  prompt edit layout="$out"
else
  prompt new
fi
prompt next self="$(dirname -- "$0")" slug="$1"
