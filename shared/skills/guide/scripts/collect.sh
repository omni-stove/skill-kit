#!/usr/bin/env bash
# Print the synced domain's flow (the mermaid block under "## Flow" in the kit's
# domains/<domain>/README.md), then one line per installed skill as <name><TAB><description>,
# read from .agents/skills/*/SKILL.md, then what to do with them.
set -euo pipefail
. "$(dirname -- "$0")/../../../refs/prompt.sh"

[ $# -eq 0 ] || { echo "usage: collect.sh" >&2; exit 2; }
[ -d .agents/skills ] || { echo "collect.sh: no .agents/skills here — run it from the repo root after skill-kit <domain> sync" >&2; exit 1; }

kit="$(cd -P -- "$(dirname -- "$0")/../../../.." && pwd)"
domain="$(cat .agents/refs/domain 2>/dev/null || true)"
readme="$kit/domains/$domain/README.md"
if [ -n "$domain" ] && [ -f "$readme" ]; then
  echo "# $domain flow"
  awk '/^## Flow/{f=1; next} f&&/^```mermaid/{p=1} p{print} p&&/^```$/{exit}' "$readme"
  echo
fi

echo "# skills"
for md in .agents/skills/*/SKILL.md; do
  [ -f "$md" ] || continue
  awk -F': ' '
    NR==1 && $0!="---" {exit}
    NR>1 && $0=="---" {exit}
    $1=="name" {n=$2}
    $1=="description" {sub(/^description: /, ""); d=$0}
    END {if (n!="" && n!="guide") printf "%s\t%s\n", n, d}' "$md"
done

prompt collect
