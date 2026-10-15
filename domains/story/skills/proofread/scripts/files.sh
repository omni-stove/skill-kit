#!/bin/sh
# Usage: files.sh <directory | file in it>
# Prints the directory's .txt files one per line, in natural sort order —
# synopsis and dotfiles excluded — then how to proofread them.
set -eu
[ $# -eq 1 ] || { echo "usage: files.sh <directory | file>" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
set -- "$(local_path "$1")"
if [ -d "$1" ]; then dir=$(cd "$1" && pwd)
elif [ -f "$1" ]; then dir=$(cd "$(dirname -- "$1")" && pwd)
else echo "files: no such file or directory: $1" >&2; exit 1; fi
files=$(find "$dir" -maxdepth 1 -type f -name '*.txt' ! -name 'synopsis*' ! -name '.*' | sort -V)
printf '%s\n' "$files" | grep . || true
if [ "$(printf '%s\n' "$files" | grep -c .)" -eq 1 ]; then
  echo "One file: read it and check it yourself for these items:"
else
  echo "Launch one Agent per file above in parallel, passing the file path and these items:"
fi
cat <<NEXT
- Typos — homophone conversion mistakes, okurigana errors, dropped or duplicated particles, missing or extra characters, misspelled katakana words
- Tense confusion (narration only) — flashback or exposition indistinguishable from the present scene, event order unfollowable because of tense. Do not report mere mixing of た-form and る-form
- Notation variance — the same word in both kanji and hiragana, inconsistent proper-noun spelling
- Do not report intentional expression such as speech quirks or dialect
Then run $(dirname -- "$0")/save.sh "$1" with the results on stdin.
NEXT
