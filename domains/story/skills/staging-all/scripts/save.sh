#!/bin/sh
# Usage: save.sh <directory | file in it>  (report text on stdin)
# Writes the report to this directory's record, out/staging-all/<dir key>.md,
# keeping only the latest run's report, and prints the record path and the fix flow.
set -eu
[ $# -eq 1 ] || { echo "usage: save.sh <directory | file>  (report on stdin)" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
set -- "$(local_path "$1")"
if [ -d "$1" ]; then dir=$(cd "$1" && pwd)
elif [ -f "$1" ]; then dir=$(cd "$(dirname -- "$1")" && pwd)
else echo "save: no such file or directory: $1" >&2; exit 1; fi
key=$(echo "$dir" | tr '/' '_')
mkdir -p out/staging-all
record="out/staging-all/$key.md"
cat > "$record"
echo "$record"
cat <<'NEXT'
Ask via AskUserQuestion which findings to fix — options (multiSelect): 「すべて修正」 first,
then the top 3 findings in priority order. For each touched file that a checking agent
holds, send it via SendMessage its selected findings and the instruction to edit its file,
re-check the edited scenes against the loaded rules once, and report what was fixed and
what remains; a file you checked yourself, edit and re-check the same way. Report the
results.
NEXT
