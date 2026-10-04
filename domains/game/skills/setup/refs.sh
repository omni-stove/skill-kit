#!/bin/sh
[ -f .agents/refs/engine.sh ] || { echo "setup: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
cat .agents/refs/setup-rules.md
