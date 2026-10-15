#!/usr/bin/env bash
# Run the repo's generate task and print the files it wrote, one per line: the generated
# files that belong in the commit. A generated file whose diff is not listed changed for
# some other reason and stays out.
# usage: regenerate.sh
set -euo pipefail

next() {
  echo "==> next: git add your changes and the generated files listed above, commit, then run .agents/skills/create-pr/scripts/push.sh" >&2
}

[ "$#" -eq 0 ] || { echo "usage: regenerate.sh" >&2; exit 2; }

if ! mise tasks ls --no-header 2>/dev/null | awk '{print $1}' | grep -qx generate; then
  echo "==> no generate task in this repo; nothing regenerated" >&2
  next
  exit 0
fi

marker="$(mktemp)"
trap 'rm -f "$marker"' EXIT
# A rewrite with unchanged content still counts, so written files are found by mtime; -nt
# compares whole seconds on macOS bash 3.2, so the marker must be a second older.
sleep 1
mise run generate >&2

git ls-files -m -o --exclude-standard | sort -u | while IFS= read -r file; do
  if [ -e "$file" ] && [ "$file" -nt "$marker" ]; then
    printf '%s\n' "$file"
  fi
done
next
