#!/bin/sh
# Tail this repo's engine runtime log: recent call-site messages (deduped, by frequency),
# then runtime exceptions, then how to read them. --prev tails the previous session's log.
[ -f .agents/refs/engine.sh ] || { echo "tail: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
case "${1:-}" in
  "") log=$(runtime_log) ;;
  --prev) log=$(runtime_log_prev) ;;
  *) echo "usage: tail.sh [--prev]" >&2; exit 2 ;;
esac
mcp=$(control_mcp)
if [ -n "$mcp" ] && [ -z "${1:-}" ]; then
  echo "==> an engine-control MCP is wired up: the $mcp tools read the live console as structured, per-message entries; below is the same output scraped from the log"
fi
echo "== recent messages (call site × count) =="
grep -oE "$(call_site_pattern)" "$log" 2>/dev/null | tail -100 | sort | uniq -c | sort -rn
echo "== runtime exceptions =="
grep -nE "$(runtime_error_pattern)" "$log" 2>/dev/null | tail -50
cat <<NEXT
==> next: this project's own frames point into $(source_root); engine/plugin frames ($(third_party)) and license/entitlement boilerplate are noise. The log is append-only, often huge, updates live, and repeats a message logged every frame. For a specific tag ([Combat], [AI], ...): grep -nF "[Combat]" "$log" | tail -50. To watch output while the user runs a scenario: tail -f "$log". For the previous session: $0 --prev. Cross-check the call site in the real source before proposing a change — log line numbers go stale.
NEXT
