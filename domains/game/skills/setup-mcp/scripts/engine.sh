#!/bin/sh
# Print this repo's engine, the MCP prefix recorded now, the MCP servers configured, and the
# steps to wire a server up.
[ -f .agents/refs/engine.sh ] || { echo "engine: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
printf 'engine\t%s\n' "$(engine_name)"
printf 'control_mcp\t%s\n' "$(control_mcp)"
if command -v claude >/dev/null 2>&1; then
  echo "== claude mcp list =="
  claude mcp list 2>&1 || true
fi
cat <<'EOF2'
==> next: the right bridge depends on the engine above. Ask the user which engine-control MCP server they want (its name/package/command, or a URL for a remote server); with none in mind, say plainly that they need to pick a bridge for their engine; when they only want log-based behaviour, stop here. Never invent a server package or command — use what the user provides or a well-known one they name. Configure it project-scoped so it travels with the repo: claude mcp add --scope project <name> -- <command> [args...], or claude mcp add --scope project --transport http <name> <url>; a config blob the user gives goes into .mcp.json, merged into its mcpServers object, with secrets as env references, never literal tokens. Run claude mcp list (claude mcp get <name> for detail) and confirm the server connects; on failure surface the error and the fix (missing binary, auth, wrong path) and stop — the user may need to restart the session for a new server's tools to appear. Then run .agents/skills/setup-mcp/scripts/record.sh <tool prefix, e.g. mcp__unity__>.
EOF2
