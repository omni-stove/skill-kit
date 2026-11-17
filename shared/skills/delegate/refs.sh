#!/bin/sh
[ -f .agents/refs/llm-instruction-rules.md ] || { echo "delegate: .agents/refs/llm-instruction-rules.md not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit {game|story|code} sync\`, then stop." >&2; exit 1; }
cat .agents/refs/llm-instruction-rules.md
