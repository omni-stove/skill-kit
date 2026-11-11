#!/bin/sh
# Print this repo's engine commands, one per line — control-MCP prefix, build, run, headless —
# and the path to take: Computer Use on the editor, an MCP bridge, headless, or build and run.
# A value beginning with # is a human instruction, not a runnable command.
[ -f .agents/refs/engine.sh ] || { echo "commands: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
ctrl=$(control_mcp); build=$(build_cmd); run=$(run_cmd); headless=$(headless_cmd)
printf 'ctrl\t%s\n' "$ctrl"
printf 'build\t%s\n' "$build"
printf 'run\t%s\n' "$run"
printf 'headless\t%s\n' "$headless"
case $ctrl in
  *computer*) prompt gui ctrl="$ctrl" ;;
  ?*) prompt mcp ctrl="$ctrl" ;;
  *) if [ "${headless#\#}" = "$headless" ]; then prompt headless; else prompt build; fi ;;
esac
prompt confirm
