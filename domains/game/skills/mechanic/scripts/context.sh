#!/bin/sh
# Print this repo's mechanics dir and GDD path, then the mechanic format contract.
# $1 = lowercase-dashed slug -> also print the target file path for that mechanic.
. .agents/refs/layout.sh
echo "mechanics: $(mechanics)"
echo "gdd_file: $(gdd_file)"
[ -n "${1:-}" ] && echo "mechanic_file: $(mechanic_file "$1")"
echo "--- mechanic-format.md ---"
cat .agents/refs/mechanic-format.md
