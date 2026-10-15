#!/bin/sh
[ -f .agents/refs/mise-rules.md ] || { echo "init: .agents/refs/mise-rules.md not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit {game|story|code} sync\`, then stop." >&2; exit 1; }
cat .agents/refs/mise-rules.md
