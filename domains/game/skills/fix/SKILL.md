---
name: fix
description: Inspect the compile errors and warnings the game engine is currently emitting (from its build/editor log) and fix them in the project's own code. Use when the user asks to see/fix engine errors or warnings, clean up the console, or resolve compile errors / deprecation warnings in this game project.
---

Run `.agents/skills/fix/refs.sh`

# Fix engine compile errors / warnings

Pull the compile errors and warnings the engine is emitting and fix the project's own
code. Follow the loaded rules — wire any reference in code, verify by recompiling, never
through the GUI.

Get the current errors. With an engine-control MCP
(`sh -c '. .agents/refs/engine.sh; control_mcp'` non-empty), read them from its structured
console. Otherwise run `.agents/skills/fix/scripts/errors.sh`. If that can't find
`.agents/refs/engine.sh`, the kit isn't synced into this repo — tell the user to run
`skill-kit game sync`, then stop.

Fix errors before warnings — errors block the build.

Confirm each hit in the real source before editing:
`grep -rn "<API/identifier>" "$(sh -c '. .agents/refs/engine.sh; source_root')"`. A hit
that's in the log but not in source is a stale leftover — ignore it; log line numbers go
stale too.

Read the offending source before changing a type mismatch or undefined reference. For a
deprecation with a mechanical replacement, `grep -rl … | xargs sed` scoped to the source
root, then confirm none remain. Edit only files under the source root; leave anything
matching `sh -c '. .agents/refs/engine.sh; third_party'`. For anything without an obvious,
safe replacement, show the offending code and confirm the approach with the user.

Make the fix take effect. Through the MCP: trigger the recompile and re-read the errors to
confirm they're gone. Without it: relay `sh -c '. .agents/refs/engine.sh; recompile_hint'`
for the user to run.
