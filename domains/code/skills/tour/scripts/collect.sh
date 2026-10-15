#!/usr/bin/env bash
# Print every @feature JSDoc block under a directory, each headed by its file's path: the
# feature map of the app.
# usage: collect.sh <dir>   (the app's directory; . for the repo)
set -euo pipefail

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
echo "==> next: group the features into sections and outline the tour. Present the whole picture first — what the app is for and its feature groups — then walk the groups one at a time in plain words. After each group, ask whether to go on, go deeper, take a question, or skip. For a deeper look, read the component and explain from its implementation." >&2
