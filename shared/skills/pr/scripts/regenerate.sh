#!/usr/bin/env bash
# Rerun generate for the changed paths and print the files it wrote, one per line: the
# generated files that belong in the commit. A generated file whose diff is not listed
# changed for some other reason and stays out.
# With a turbo.json at the root, generate runs for the package each path belongs to and
# the packages that depend on it; otherwise the repo's generate task runs, when there is one.
# usage: regenerate.sh <changed path>...
set -euo pipefail
. "$(dirname -- "$0")/../../../refs/prompt.sh"

[ "$#" -ge 1 ] || { echo "usage: regenerate.sh <changed path>..." >&2; exit 2; }

cmd=()
if [ -f turbo.json ]; then
  filters=()
  for path in "$@"; do
    dir="$path"
    [ -d "$dir" ] || dir="$(dirname "$dir")"
    while [ "$dir" != . ] && [ "$dir" != / ] && [ ! -f "$dir/package.json" ]; do
      dir="$(dirname "$dir")"
    done
    # The root package.json is the whole workspace; a filter on it regenerates every package.
    if [ ! -f "$dir/package.json" ] || [ "$dir" = . ]; then
      echo "==> skip (no package): $path" >&2
      continue
    fi
    name="$(node -p "require('./$dir/package.json').name")"
    # Dependents (...pkg) come along because an upstream type or schema change lands in
    # their generated files.
    filters+=("--filter=...$name")
  done
  # A cache hit replays the output without writing the files, which the mtime check below
  # would miss, so the run is forced.
  [ "${#filters[@]}" -eq 0 ] || cmd=(pnpm exec turbo run generate --force "${filters[@]}")
elif mise tasks ls --no-header 2>/dev/null | awk '{print $1}' | grep -qx generate; then
  cmd=(mise run generate)
fi

if [ "${#cmd[@]}" -eq 0 ]; then
  prompt nothing >&2
  exit 0
fi

marker="$(mktemp)"
trap 'rm -f "$marker"' EXIT
# A rewrite with unchanged content still counts, so written files are found by mtime; -nt
# compares whole seconds on macOS bash 3.2, so the marker must be a second older.
sleep 1
"${cmd[@]}" >&2

git ls-files -m -o --exclude-standard | sort -u | while IFS= read -r file; do
  if [ -e "$file" ] && [ "$file" -nt "$marker" ]; then
    printf '%s\n' "$file"
  fi
done
prompt regenerated >&2
