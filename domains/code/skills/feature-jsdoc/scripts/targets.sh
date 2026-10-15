#!/usr/bin/env bash
# List what to document, one per line as <path><TAB><role>: every pages/routes directory
# under a src/ that holds .tsx as `page`, every components directory as `component`, or the
# one path given as `path`.
# usage: targets.sh <dir> [all|pages|components|<path-under-dir>]   (default: all)
set -euo pipefail
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"

usage() { echo "usage: targets.sh <dir> [all|pages|components|<path-under-dir>]   (<dir>: the app's directory; . for the repo)" >&2; exit 2; }
[ "$#" -ge 1 ] && [ "$#" -le 2 ] && [ -d "$1" ] || usage
dir="${1%/}"
scope="${2:-all}"

case "$scope" in
  all|pages|components) ;;
  */*|*.*)
    [ -e "$dir/$scope" ] || { echo "targets: $dir/$scope not found — fix the path and rerun" >&2; exit 1; }
    printf '%s\t%s\n' "${dir#./}/$scope" path
    exit 0
    ;;
  *) usage ;;
esac

find "$dir" \( -name node_modules -o -name generated \) -prune -o -path '*/src/*' -name '*.tsx' -print \
  | sed -E 's#(.*/src)/.*#\1#' | sort -u \
  | while IFS= read -r src; do
      if [ "$scope" != components ]; then
        for d in ui/pages ui/page pages routes; do
          if [ -d "$src/$d" ]; then printf '%s\t%s\n' "${src#./}/$d" page; fi
        done
      fi
      if [ "$scope" != pages ]; then
        for d in ui/components components; do
          if [ -d "$src/$d" ]; then printf '%s\t%s\n' "${src#./}/$d" component; fi
        done
      fi
    done
prompt next >&2
