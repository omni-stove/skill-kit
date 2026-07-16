#!/bin/sh
# Print this repo's GDD file path and design root, then the GDD format contract.
. .agents/refs/layout.sh
echo "gdd_file: $(gdd_file)"
echo "design_root: $(design_root)"
echo "--- gdd-format.md ---"
cat .agents/refs/gdd-format.md
