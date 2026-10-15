#!/bin/sh
# Print this repo's engine commands, one per line — control-MCP prefix, build, run, headless —
# and the path to take. A value beginning with # is a human instruction, not a runnable command.
[ -f .agents/refs/engine.sh ] || { echo "commands: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
ctrl=$(control_mcp); build=$(build_cmd); run=$(run_cmd); headless=$(headless_cmd)
printf 'ctrl\t%s\n' "$ctrl"
printf 'build\t%s\n' "$build"
printf 'run\t%s\n' "$run"
printf 'headless\t%s\n' "$headless"
if [ -n "$ctrl" ]; then
  echo "==> next: drive Play Mode, tests or the build through the $ctrl tools."
elif [ "${headless#\#}" = "$headless" ]; then
  echo "==> next: run the headless command; its output goes to a log you read."
else
  echo "==> next: build with the build command when a build step applies, then run with the run command."
fi
cat <<'EOF2'
A command beginning with # is a human instruction, not runnable: relay it verbatim and wait for the user. Let a scriptable run start, then confirm it is up — the process is alive, a window or port opened, or the expected startup line appeared; keep a long-running process in the background and read its log while it runs. A successful build proves it compiles, not that the change behaves: drive the actual flow and read what the running game printed before calling it done, by the loaded rules.
EOF2
