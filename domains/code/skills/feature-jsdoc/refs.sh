#!/bin/sh
[ -f .agents/refs/feature-jsdoc-rules.md ] || { echo "feature-jsdoc: .agents/refs/feature-jsdoc-rules.md not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit code sync\`, then stop." >&2; exit 1; }
cat .agents/refs/feature-jsdoc-rules.md
