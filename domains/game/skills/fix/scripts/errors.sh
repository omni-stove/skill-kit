#!/bin/sh
# List the latest compile errors/warnings from this repo's engine build log, scoped to the
# project's own source (newest compile only), then the steps to fix them. With an
# engine-control MCP wired up, says to read them from its console instead.
[ -f .agents/refs/engine.sh ] || { echo "errors: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
mcp=$(control_mcp)
if [ -n "$mcp" ]; then
  prompt read-mcp mcp="$mcp"
else
  errors=$(grep -oE "$(source_root)/[^(]*$(compile_error_pattern)" "$(build_log)" 2>/dev/null | tail -200 | sort -u)
  if [ -z "$errors" ]; then
    prompt clean
    exit 0
  fi
  echo "==> compile errors and warnings"
  printf '%s\n' "$errors"
fi
prompt next source_root="$(source_root)" third_party="$(third_party)"
if [ -n "$mcp" ]; then
  prompt recompile-mcp mcp="$mcp"
else
  prompt recompile-log hint="$(recompile_hint)"
fi
