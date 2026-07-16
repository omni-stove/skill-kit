#!/bin/sh
# List the latest compile errors/warnings from this repo's engine build log, scoped to
# the project's own source (newest compile only). No output means a clean build.
. .agents/refs/engine.sh
grep -oE "$(source_root)/[^(]*$(compile_error_pattern)" "$(build_log)" 2>/dev/null | tail -200 | sort -u
