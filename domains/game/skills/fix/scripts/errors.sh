#!/bin/sh
# List the latest compile errors/warnings from this repo's engine build log, scoped to
# the project's own source (newest compile only). No output means a clean build.
[ -f .agents/refs/engine.sh ] || { echo "errors: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
grep -oE "$(source_root)/[^(]*$(compile_error_pattern)" "$(build_log)" 2>/dev/null | tail -200 | sort -u
