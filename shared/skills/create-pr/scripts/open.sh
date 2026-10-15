#!/usr/bin/env bash
# Open a PR for the pushed current branch, with a body of the four template sections,
# assigned to the caller, and print its URL and the report to give.
# usage: open.sh [--base <branch>] [--draft] [--label <name>]... <title> <purpose> <approach> <verification> [review-points]
# A multi-line section is one argument with real newlines ($'line 1\nline 2'); a literal \n
# stays as text.
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
usage: open.sh [--base <branch>] [--draft] [--label <name>]... <title> <purpose> <approach> <verification> [review-points]
A multi-line section is one argument with real newlines, e.g. $'line 1\nline 2'; a literal \n stays as text.
USAGE
  exit 2
}

base=main
flags=()
args=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --base) [ "$#" -ge 2 ] || usage; base="$2"; shift ;;
    --label) [ "$#" -ge 2 ] || usage; flags+=(--label "$2"); shift ;;
    --draft) flags+=(--draft) ;;
    -*) usage ;;
    *) args+=("$1") ;;
  esac
  shift
done
set -- ${args[@]+"${args[@]}"}
[ "$#" -ge 4 ] && [ "$#" -le 5 ] || usage
title="$1"

body_file="$(mktemp)"
trap 'rm -f "$body_file"' EXIT
cat > "$body_file" <<MARKDOWN
## 目的

${2:-(記載なし)}

## 実装方針

${3:-(記載なし)}

## 確認方法

${4:-(記載なし)}

## 見て欲しいポイント

${5:-特になし}
MARKDOWN

gh pr create --base "$base" --title "$title" --assignee @me --body-file "$body_file" ${flags[@]+"${flags[@]}"}
echo "==> next: report the PR URL above and the change in one line" >&2
