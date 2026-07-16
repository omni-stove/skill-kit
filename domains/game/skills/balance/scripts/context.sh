#!/bin/sh
# Print this repo's balance dir, mechanics dir, and GDD path, then the balance format
# contract. $1 = lowercase-dashed slug -> also print the target file path.
. .agents/refs/layout.sh
echo "balance: $(balance)"
echo "mechanics: $(mechanics)"
echo "gdd_file: $(gdd_file)"
[ -n "${1:-}" ] && echo "balance_file: $(balance_file "$1")"
echo "--- balance-format.md ---"
cat .agents/refs/balance-format.md
