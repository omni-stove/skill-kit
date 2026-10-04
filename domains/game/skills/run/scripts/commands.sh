#!/bin/sh
# Print this repo's engine commands, one per line: control-MCP prefix, build, run,
# headless. A value beginning with # is a human instruction, not a runnable command.
[ -f .agents/refs/engine.sh ] || { echo "commands: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
printf 'ctrl\t%s\n' "$(control_mcp)"
printf 'build\t%s\n' "$(build_cmd)"
printf 'run\t%s\n' "$(run_cmd)"
printf 'headless\t%s\n' "$(headless_cmd)"
