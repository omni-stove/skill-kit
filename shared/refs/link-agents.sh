#!/usr/bin/env bash
# Link each untracked path under the repo's .agents into a worktree and exclude it, so the
# worktree has the kit while no commit takes it. The worktree checks out only the tracked rest;
# git reads no .gitignore that is a link, so the exclude stands in for the kit's .gitignore files.
# usage: link-agents.sh <worktree>   (run from the main checkout)
set -euo pipefail

[ $# -eq 1 ] && [ -d "$1" ] || { echo "usage: link-agents.sh <worktree>" >&2; exit 2; }
dir="$1"
root="$(git rev-parse --show-toplevel)"
common="$(git rev-parse --path-format=absolute --git-common-dir)"

git -C "$root" ls-files --others --directory -z -- .agents | while IFS= read -r -d '' p; do
  p="${p%/}"
  [ "$(basename -- "$p")" != .gitignore ] || continue
  [ -e "$dir/$p" ] || [ -L "$dir/$p" ] || { mkdir -p "$(dirname -- "$dir/$p")"; ln -s "$root/$p" "$dir/$p"; }
  git -C "$dir" check-ignore -q "$p" || echo "/$p" >> "$common/info/exclude"
done
