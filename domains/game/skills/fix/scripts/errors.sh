#!/bin/sh
# List the latest compile errors/warnings from this repo's engine build log, scoped to the
# project's own source (newest compile only), then the steps to fix them. With an
# engine-control MCP wired up, says to read them from its console instead.
[ -f .agents/refs/engine.sh ] || { echo "errors: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
mcp=$(control_mcp)
if [ -n "$mcp" ]; then
  echo "==> read the current compile errors and warnings through the $mcp tools (structured console)"
else
  errors=$(grep -oE "$(source_root)/[^(]*$(compile_error_pattern)" "$(build_log)" 2>/dev/null | tail -200 | sort -u)
  if [ -z "$errors" ]; then
    echo "==> clean build: no compile error or warning in the latest compile. Report that and stop."
    exit 0
  fi
  echo "==> compile errors and warnings"
  printf '%s\n' "$errors"
fi
cat <<NEXT
==> next: fix errors before warnings, by the loaded rules. Confirm each hit in the source before editing: grep -rn "<API/identifier>" $(source_root) — a hit in the log but not in source is a stale leftover; log line numbers go stale too. Edit only files under $(source_root); leave anything matching: $(third_party). Where no replacement is obvious and safe, show the offending code and confirm the approach with the user.
NEXT
if [ -n "$mcp" ]; then
  echo "Then trigger the recompile through the $mcp tools and re-read the errors to confirm they are gone."
else
  echo "Then relay to the user: $(recompile_hint)"
fi
