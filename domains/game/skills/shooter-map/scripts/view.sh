#!/bin/sh
# Usage: view.sh <slug>
# Draws docs/design/maps/<slug>.json as docs/design/maps/<slug>.svg in the top, front, side and
# 3D views. Prints the SVG path and the review step.
set -eu
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
[ $# -eq 1 ] || { echo "usage: view.sh <slug>" >&2; exit 2; }
out=$(sh "$(dirname -- "$0")/../../../refs/map-view.sh" "$1")
printf '%s\n' "$out"
prompt view svg="${out#svg	}" self="$(dirname -- "$0")" slug="$1"
