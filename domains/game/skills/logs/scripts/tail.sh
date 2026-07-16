#!/bin/sh
# Tail this repo's engine runtime log: recent call-site messages (deduped, by frequency),
# then runtime exceptions. $1 overrides the log (default: the current run).
. .agents/refs/engine.sh
log=${1:-$(runtime_log)}
echo "== recent messages (call site × count) =="
grep -oE "$(call_site_pattern)" "$log" 2>/dev/null | tail -100 | sort | uniq -c | sort -rn
echo "== runtime exceptions =="
grep -nE "$(runtime_error_pattern)" "$log" 2>/dev/null | tail -50
