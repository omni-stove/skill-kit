#!/bin/sh
# Print this repo's engine name.
[ -f .agents/refs/engine.sh ] || { echo "engine: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
engine_name
