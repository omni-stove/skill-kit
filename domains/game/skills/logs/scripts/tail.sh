#!/bin/sh
# Tail this repo's engine runtime log: recent call-site messages (deduped, by frequency),
# then runtime exceptions, then how to read them. --prev tails the previous session's log.
[ -f .agents/refs/engine.sh ] || { echo "tail: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
case "${1:-}" in
  "") log=$(runtime_log) ;;
  --prev) log=$(runtime_log_prev) ;;
  *) echo "usage: tail.sh [--prev]" >&2; exit 2 ;;
esac
mcp=$(control_mcp)
if [ -n "$mcp" ] && [ -z "${1:-}" ]; then
  prompt mcp mcp="$mcp"
fi
echo "== recent messages (call site × count) =="
grep -oE "$(call_site_pattern)" "$log" 2>/dev/null | tail -100 | sort | uniq -c | sort -rn
echo "== runtime exceptions =="
grep -nE "$(runtime_error_pattern)" "$log" 2>/dev/null | tail -50
prompt next source_root="$(source_root)" third_party="$(third_party)" log="$log" self="$0"
