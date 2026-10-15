#!/bin/sh
# Print this repo's engine, the MCP prefix recorded now, the MCP servers configured, and the
# steps to wire a server up.
[ -f .agents/refs/engine.sh ] || { echo "engine: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
printf 'engine\t%s\n' "$(engine_name)"
printf 'control_mcp\t%s\n' "$(control_mcp)"
if command -v claude >/dev/null 2>&1; then
  echo "== claude mcp list =="
  claude mcp list 2>&1 || true
fi
prompt wire
