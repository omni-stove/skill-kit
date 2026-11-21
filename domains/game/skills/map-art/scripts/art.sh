#!/bin/sh
# Usage: art.sh [theme]
# Prints the engine, the theme, its layout files, the piece kinds and grids they use, the
# module directory, the headless command, the log and Blender, then the step that models
# the modules or swaps them in.
# Without a theme it uses the only one the layout files name, else prints the themes and
# the step that picks one.
set -eu
[ -f .agents/refs/engine.sh ] || { echo "art: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
[ $# -le 1 ] || { echo "usage: art.sh [theme]" >&2; exit 2; }
self=$(dirname -- "$0")
maps=docs/design/maps
ls "$maps"/*.json >/dev/null 2>&1 || { echo "art: no layout file in $maps — write a map's layout file there first." >&2; exit 1; }
theme=${1:-}
if [ -z "$theme" ]; then
  themes=$(jq -r '.theme // empty' "$maps"/*.json | sort -u)
  unthemed=$(for f in "$maps"/*.json; do jq -e '.theme' "$f" >/dev/null || echo "$f"; done)
  if [ -n "$themes" ] && [ "$(printf '%s\n' "$themes" | wc -l)" -eq 1 ] && [ -z "$unthemed" ]; then
    theme=$themes
  else
    for t in $themes; do printf 'theme\t%s\n' "$t"; done
    for f in $unthemed; do printf 'unthemed\t%s\n' "$f"; done
    prompt theme self="$self"
    exit 0
  fi
fi
printf '%s' "$theme" | grep -Eq '^[a-z][a-z0-9]*(-[a-z0-9]+)*$' || { echo "art: theme must be kebab-case: $theme" >&2; exit 1; }
files=$(for f in "$maps"/*.json; do [ "$(jq -r '.theme // empty' "$f")" != "$theme" ] || echo "$f"; done)
[ -n "$files" ] || { echo "art: no layout file in $maps has theme $theme — set the theme in the layout files to dress, then rerun." >&2; exit 1; }
modules="$(source_root)/Modules/$theme"
blender=$(command -v blender || true)
[ -n "$blender" ] || [ ! -x /Applications/Blender.app/Contents/MacOS/Blender ] || blender=/Applications/Blender.app/Contents/MacOS/Blender
printf 'engine\t%s\n' "$(engine_name)"
printf 'theme\t%s\n' "$theme"
for f in $files; do printf 'map\t%s\n' "$f"; done
# shellcheck disable=SC2086
printf 'kinds\t%s\n' "$(jq -r '.pieces[].kind' $files | sort -u | tr '\n' ' ' | sed 's/ $//')"
# shellcheck disable=SC2086
printf 'grid\t%s\n' "$(jq -r '.grid' $files | sort -u | tr '\n' ' ' | sed 's/ $//')"
printf 'modules\t%s\n' "$modules"
printf 'headless\t%s\n' "$(headless_cmd)"
printf 'log\t%s\n' "$(runtime_log)"
printf 'blender\t%s\n' "${blender:-missing}"
if [ -d "$modules" ] && [ -n "$(ls -A "$modules")" ]; then
  prompt swap modules="$modules" source_root="$(source_root)"
else
  [ -n "$blender" ] || { echo "art: Blender not found — have the user install it or put blender on PATH, then rerun." >&2; exit 1; }
  prompt model theme="$theme" modules="$modules" blender="$blender"
  prompt swap modules="$modules" source_root="$(source_root)"
fi
