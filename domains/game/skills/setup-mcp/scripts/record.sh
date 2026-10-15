#!/bin/sh
# Usage: record.sh <tool-prefix>   ("" unsets it)
# Record an engine-control MCP tool prefix as control_mcp in this repo's own
# .agents/refs/engine.sh — the kit's symlinked default is turned into a real file first — and
# print the value that now resolves, check that .mcp.json configures the server the prefix
# names and that it connects, then what to verify and tell the user.
set -eu
[ $# -eq 1 ] || { echo "usage: record.sh <tool-prefix>   (e.g. mcp__unity__; \"\" to unset)" >&2; exit 2; }
f=.agents/refs/engine.sh
[ -e "$f" ] || { echo "record: $f not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
if [ -L "$f" ]; then
  tmp=$(mktemp)
  cat "$f" > "$tmp"
  rm "$f"
  mv "$tmp" "$f"
  echo "copied	$f — the kit's default is now this repo's own file; sync leaves it alone"
fi
grep -q '^control_mcp()' "$f" || { echo "record: no control_mcp() in $f — add a line: control_mcp() { echo \"$1\"; }" >&2; exit 1; }
tmp=$(mktemp)
sed "s|^control_mcp() *{.*|control_mcp()        { echo \"$1\"; }|" "$f" > "$tmp"
mv "$tmp" "$f"
printf 'control_mcp\t%s\n' "$(sh -c ". $f; control_mcp")"
if [ -n "$1" ]; then
  name=${1#mcp__}; name=${name%__}
  if [ -f .mcp.json ] && grep -q "\"$name\"" .mcp.json; then
    echo "server	$name — configured in .mcp.json"
  else
    echo "warning	.mcp.json has no server named \"$name\" (the prefix mcp__<name>__ must match the server's name) — configure it with claude mcp add --scope project $name ..."
  fi
  if command -v claude >/dev/null 2>&1; then
    echo "== claude mcp get $name =="
    claude mcp get "$name" 2>&1 || echo "warning	$name does not connect — fix that before relying on it"
  fi
  cat <<EOF2
==> next: resolve any warning above. Confirm a tool named ${1}* exists in this session and, where you can, exercise one read-only engine tool (e.g. read the live console). Run git status: .mcp.json and $f appear as real, tracked changes and nothing else. Tell the user which server is wired up, that it is project-scoped and shared via the repo, and that reading errors, reading logs and running the game now prefer the MCP and fall back to logs when it is unavailable. To undo: claude mcp remove --scope project <name>, then $0 "".
EOF2
else
  echo "==> next: the kit is back to log-scraping; run claude mcp remove --scope project <name> if the server is still configured, and tell the user."
fi
