#!/bin/sh
# Print this repo's engine commands, one per line: control-MCP prefix, build, run,
# headless. A value beginning with # is a human instruction, not a runnable command.
. .agents/refs/engine.sh
printf 'ctrl\t%s\n' "$(control_mcp)"
printf 'build\t%s\n' "$(build_cmd)"
printf 'run\t%s\n' "$(run_cmd)"
printf 'headless\t%s\n' "$(headless_cmd)"
