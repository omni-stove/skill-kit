#!/usr/bin/env bash
# Print every @feature JSDoc block under a directory, each headed by its file's path: the
# feature map of the app.
# usage: collect.sh <dir>   (the app's directory; . for the repo)
set -euo pipefail
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"

[ "$#" -eq 1 ] && [ -d "$1" ] || { echo "usage: collect.sh <dir>   (an existing directory; . for the repo)" >&2; exit 2; }
dir="${1%/}"

files="$(grep -rl --include='*.tsx' --include='*.jsx' --include='*.ts' --include='*.js' --include='*.vue' --include='*.svelte' \
  --exclude-dir=node_modules --exclude-dir=generated -e '@feature' "$dir" || true)"
[ -n "$files" ] || { echo "collect: no @feature JSDoc under $dir — there is nothing to tour; tell the user" >&2; exit 1; }

printf '%s\n' "$files" | sort | while IFS= read -r f; do
  echo "===== ${f#./} ====="
  awk '/@feature/{p=1} p{print} p&&/\*\//{p=0}' "$f"
  echo
done
prompt next >&2
