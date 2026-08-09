#!/bin/sh
# translation-pairs.sh <path> — resolve source⇔translation pairs for the translation
# skills. <path> is a Japanese source file, its en/ translation, or a directory of
# sources; a translation always lives at en/<same filename> beside its source.
# Prints tab-separated lines:
#   glossary <path> exists|missing
#   pair|source-only|en-only <source> <translation>
# Directory listing: the directory's *.txt and *.md in natural sort order,
# synopsis.* skipped; en-only lines cover en/ files whose source is gone.
set -eu

[ $# -eq 1 ] || { echo "usage: translation-pairs.sh <source-file | en-file | directory>" >&2; exit 2; }
p=$1

emit() { printf '%s\t%s\t%s\n' "$1" "$2" "$3"; }

status_of() {
	if [ -f "$1" ] && [ -f "$2" ]; then echo pair
	elif [ -f "$1" ]; then echo source-only
	else echo en-only; fi
}

if [ -d "$p" ]; then
	dir=${p%/}
else
	[ -f "$p" ] || { echo "translation-pairs: no such file or directory: $p" >&2; exit 1; }
	parent=$(dirname -- "$p")
	name=$(basename -- "$p")
	if [ "$(basename -- "$parent")" = en ]; then
		dir=$(dirname -- "$parent")
	else
		dir=$parent
	fi
	src=$dir/$name
fi

g=$dir/en/glossary.md
[ -f "$g" ] && emit glossary "$g" exists || emit glossary "$g" missing

if [ -n "${src-}" ]; then
	emit "$(status_of "$src" "$dir/en/$name")" "$src" "$dir/en/$name"
	exit 0
fi

for f in "$dir"/*.txt "$dir"/*.md; do
	[ -f "$f" ] || continue
	case $(basename -- "$f") in synopsis.*) continue ;; esac
	printf '%s\n' "$f"
done | sort -V | while IFS= read -r f; do
	emit "$(status_of "$f" "$dir/en/$(basename -- "$f")")" "$f" "$dir/en/$(basename -- "$f")"
done

for f in "$dir"/en/*.txt "$dir"/en/*.md; do
	[ -f "$f" ] || continue
	b=$(basename -- "$f")
	case $b in glossary.md | synopsis.*) continue ;; esac
	[ -f "$dir/$b" ] || printf '%s\n' "$f"
done | sort -V | while IFS= read -r f; do
	emit en-only "$dir/$(basename -- "$f")" "$f"
done
