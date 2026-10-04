---
name: fix
description: Inspect the compile errors and warnings the game engine is currently emitting (from its build/editor log) and fix them in the project's own code. Use when the user asks to see/fix engine errors or warnings, clean up the console, or resolve compile errors / deprecation warnings in this game project.
---

Run `.agents/skills/fix/refs.sh`

# Fix engine compile errors / warnings

Pull the compile errors and warnings the engine is emitting and fix the project's own
code, following the loaded rules.

Get the current errors. With an engine-control MCP
(`sh -c '. .agents/refs/engine.sh; control_mcp'` non-empty), read them from its structured
console. Otherwise run `.agents/skills/fix/scripts/errors.sh`.

Fix errors before warnings.

Confirm each hit in the real source before editing:
`grep -rn "<API/identifier>" "$(sh -c '. .agents/refs/engine.sh; source_root')"`. A hit
that's in the log but not in source is a stale leftover — ignore it; log line numbers go
stale too.

Edit only files under the source root; leave anything matching
`sh -c '. .agents/refs/engine.sh; third_party'`. For anything without an obvious, safe
replacement, show the offending code and confirm the approach with the user.

Make the fix take effect. Through the MCP: trigger the recompile and re-read the errors to
confirm they're gone. Without it: relay `sh -c '. .agents/refs/engine.sh; recompile_hint'`
for the user to run.
