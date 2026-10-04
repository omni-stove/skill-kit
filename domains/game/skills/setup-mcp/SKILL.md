---
name: setup-mcp
description: Wire up an optional engine-control MCP server for this repo — configure it in .mcp.json, verify it connects, and record its tool prefix in .agents/refs/engine.sh so the kit drives the live engine instead of scraping logs. Use when the user wants to connect a Unity/Godot/Unreal MCP bridge or otherwise set up MCP for the game project (e.g. "MCPを設定して", "Unity MCPを繋いで", "setup mcp").
---

Configure an optional MCP server that can drive this repo's engine, then record it so the
kit uses it. This is opt-in: with no MCP the kit still works — reading errors, reading
logs, and running the game fall back to log-scraping and human build/run instructions.
With one wired up, those same operations can trigger recompiles, enter Play Mode, run
tests, and read the live console through a structured API.

The kit bundles no MCP server and names no specific third-party one — engines and their
bridges vary. Your job is to help the user connect *their* chosen server and record the
result. Never invent a server package or command; use what the user provides or a
well-known one they name.

## Preconditions

Run `.agents/skills/setup-mcp/scripts/engine.sh`. The right MCP bridge depends on the
printed engine (a Unity Editor bridge, a Godot bridge, etc.).

## Steps

1. **Decide the server.** Ask the user which engine-control MCP server they want (its
   name/package/command, or a URL for a remote server). If they don't have one in mind,
   say so plainly — they need to pick a bridge for their engine. If the user only wants
   log-based behaviour, stop here and leave `control_mcp` empty.

2. **Configure it in the repo, project-scoped** so it travels with the repo. Prefer the
   CLI over hand-editing when available:

   ```sh
   # stdio server (local process):
   claude mcp add --scope project <name> -- <command> [args...]
   # remote server:
   claude mcp add --scope project --transport http <name> <url>
   ```

   Either way this writes/updates `.mcp.json` at the repo root. If the user gave a config
   blob instead, write it into `.mcp.json` directly (create the file if absent, merge into
   its `mcpServers` object if present — don't clobber other servers). Put secrets in `env`
   referencing the user's environment, never inline literal tokens.

3. **Verify it connects.** Run `claude mcp list` (and `claude mcp get <name>` for detail)
   and confirm the server shows as connected. If it fails, surface the error and the fix
   (missing binary, auth, wrong path) rather than proceeding. The user may need to
   reload/restart the session for a newly added server's tools to appear.

4. **Find the tool prefix.** The server exposes tools named `mcp__<name>__<tool>`. Confirm
   the exact prefix from `claude mcp list` / the tool list.

5. **Record it in the engine contract.** Set `control_mcp` in the repo's real
   `.agents/refs/engine.sh` to echo that prefix — e.g. `control_mcp() { echo "mcp__unity__"; }`.
   If `.agents/refs/engine.sh` is still the kit's symlinked default, first turn it into a
   real override (copy the default's contents, then edit) so `skill-kit game sync` won't touch
   it. Change only `control_mcp`; leave every other function intact.

6. **Verify the wiring end to end.** Confirm the value resolves
   (`sh -c '. .agents/refs/engine.sh; control_mcp'` prints the prefix) and that a tool with
   that prefix actually exists. If you can, exercise one read-only engine tool (e.g. read
   the live console) to prove the path works.

## Verify & report

- `git status` should show `.mcp.json` and the real `.agents/refs/engine.sh` as tracked
  changes, and nothing else unexpected.
- Tell the user: which server is wired up, that it's project-scoped (shared via the repo),
  and that reading errors, reading logs, and running the game will now prefer the MCP path
  and fall back to logs if the server is ever unavailable.

## Notes

- To undo, `claude mcp remove --scope project <name>` and reset `control_mcp` to echo an
  empty string; the skills revert to log-scraping automatically.
