---
name: logs
description: Read the game engine's runtime log to see what the running game actually printed — log/print output, runtime exceptions, and their stack traces. Use when the user asks "what got logged", "show the console output", "why did it throw at runtime", or wants to inspect runtime log messages from this game project.
---

# Inspect engine runtime logs

Read what the engine printed at runtime — log/print output and runtime exceptions.

Get the recent output. With an engine-control MCP
(`sh -c '. .agents/refs/engine.sh; control_mcp'` non-empty), read the live console through
its tools for structured, per-message entries. For a session that already ended, or with
no MCP, run `.agents/skills/logs/scripts/tail.sh` — recent call-site messages (deduped by
frequency), then runtime exceptions, scoped to the current run. Pass a log path as `$1`
for a prior session:
`.agents/skills/logs/scripts/tail.sh "$(sh -c '. .agents/refs/engine.sh; runtime_log_prev')"`.
If it can't find `.agents/refs/engine.sh`, the kit isn't synced into this repo — tell the
user to run `skill-kit game sync`, then stop.

The log is append-only, often huge, updates live, and repeats a message logged every
frame. This project's own frames point into
`sh -c '. .agents/refs/engine.sh; source_root'` — engine/plugin frames and
license/entitlement boilerplate are noise.

For a specific tag — projects prefix `Debug.Log`/`print` lines with `[Combat]`, `[AI]`,
etc.: `grep -nF "[Combat]" "$(sh -c '. .agents/refs/engine.sh; runtime_log')" | tail -50`.

Cross-check the call site in the real source before proposing a change — log line numbers
go stale. To watch output stream while the user runs a scenario:
`tail -f "$(sh -c '. .agents/refs/engine.sh; runtime_log')"`.
