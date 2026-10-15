#!/usr/bin/env bash
# List what the org shares: each repo that holds composite actions, reusable workflows,
# workflow templates or a template repo, or whose description says shared, with its README
# (the install instructions are the repo's own); then this repo's workflows and tasks, and
# what to do next.
# usage: scan.sh [--org <org>] [repo...]
#   org: the owner of this repo's origin. A repo named here is listed as shared whether or
#   not it looks it.
set -euo pipefail
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
command -v jq >/dev/null || { echo "scan: jq is required — install it (mise use -g jq), then rerun" >&2; exit 1; }

usage() { echo "usage: scan.sh [--org <org>] [repo...]   (a repo named here is listed as shared)" >&2; exit 2; }
org=""
named=" "
while [ $# -gt 0 ]; do
  case "$1" in
    --org) org="${2:?}"; shift ;;
    -*) usage ;;
    *) named="$named$1 " ;;
  esac
  shift
done
self="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)"
if [ -z "$org" ]; then
  org="${self%%/*}"
  [ -n "$org" ] || { echo "scan: this directory has no GitHub repo behind it — push it first, or pass --org <org>" >&2; exit 1; }
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

gh repo list "$org" --limit 500 --json name,description,isTemplate,isArchived \
  --jq '.[] | select(.isArchived | not) | [.name, (.isTemplate | tostring), (.description // "" | gsub("[\t\n]"; " "))] | @tsv' \
  | awk -F'\t' -v self="$self" -v org="$org" 'org "/" $1 != self' >"$tmp/repos"
[ -s "$tmp/repos" ] || { echo "scan: no repository visible in $org — check gh auth status and the org name" >&2; exit 1; }
cut -f1 "$tmp/repos" >"$tmp/repos.names"
for name in $named; do
  grep -qx -- "$name" "$tmp/repos.names" || echo "scan: $name is not a repository of $org — it is left out" >&2
done

# One GraphQL query per 25 repos reads each repo's action dirs, workflow templates and
# workflow files; a repo the token cannot read comes back null and counts as holding nothing.
# Actions under .github/actions are the repo's own, so only the root and actions/ count.
tree_query='name
  rootAction: object(expression: "HEAD:action.yml") { ... on Blob { byteSize } }
  actions: object(expression: "HEAD:actions") { ... on Tree { entries { name type object { ... on Tree { entries { name } } } } } }
  templates: object(expression: "HEAD:workflow-templates") { ... on Tree { entries { name } } }
  workflows: object(expression: "HEAD:.github/workflows") { ... on Tree { entries { name object { ... on Blob { text } } } } }'
names=()
while IFS= read -r name; do names+=("$name"); done <"$tmp/repos.names"
: >"$tmp/trees"
for ((start = 0; start < ${#names[@]}; start += 25)); do
  q="query {"
  i=0
  for name in "${names[@]:start:25}"; do
    q="$q r$i: repository(owner: \"$org\", name: \"$name\") { $tree_query }"
    i=$((i + 1))
  done
  q="$q }"
  gh api graphql -f query="$q" >"$tmp/batch" 2>"$tmp/err" || true
  grep -q '"data"' "$tmp/batch" || { echo "scan: could not read the repos — $(head -1 "$tmp/err")" >&2; exit 1; }
  jq -r '
    def dirs: [.entries[]? | select(.type == "tree") | select(any(.object.entries[]?; .name == "action.yml" or .name == "action.yaml")) | .name];
    .data | to_entries[] | .value | select(. != null)
    | [.name,
       ((if .rootAction then ["(root)"] else [] end) + (.actions | if . then dirs else [] end) | join(", ")),
       ([.workflows.entries[]? | select(.object.text // "" | test("workflow_call")) | .name] | join(", ")),
       ([.templates.entries[]? | .name | select(endswith(".yml") or endswith(".yaml"))] | join(", "))]
    | @tsv' "$tmp/batch" >>"$tmp/trees"
done

awk -F'\t' -v OFS='\t' -v named="$named" '
  NR == FNR { act[$1] = $2; reu[$1] = $3; tpl[$1] = $4; next }
  {
    name = $1; template = $2; desc = $3
    shared = (name == ".github" || act[name] != "" || reu[name] != "" || tpl[name] != "" || template == "true" \
      || tolower(desc) ~ /shared|common|reusable|organization-wide|org-wide|template|共通|再利用|テンプレート/ \
      || index(named, " " name " "))
    if (!shared) { print "other", name; next }
    line = name
    if (act[name] != "") line = line OFS "actions: " act[name]
    if (reu[name] != "") line = line OFS "reusable workflows: " reu[name]
    if (tpl[name] != "") line = line OFS "workflow templates: " tpl[name]
    if (template == "true") line = line OFS "template repository"
    if (desc != "") line = line OFS desc
    print "shared", line
  }' "$tmp/trees" "$tmp/repos" >"$tmp/rows"

grep '^shared	' "$tmp/rows" | cut -f2- >"$tmp/shared" || true
grep '^other	' "$tmp/rows" | cut -f2 >"$tmp/other" || true
echo "==> shared in $org ($(wc -l <"$tmp/repos" | tr -d ' ') repos)"
[ -s "$tmp/shared" ] && cat "$tmp/shared" || echo "(none — name a repo to list it: scan.sh <repo>)"
echo "==> other repos"
[ -s "$tmp/other" ] && tr '\n' ' ' <"$tmp/other" | sed 's/ $//' || printf '(none)'
echo

cut -f1 "$tmp/shared" | while IFS= read -r name; do
  echo "==> README $org/$name"
  gh api -H "Accept: application/vnd.github.raw+json" "repos/$org/$name/readme" 2>/dev/null || echo "(no README)"
  echo
done

echo "==> this repo: .github/workflows"
found=0
for f in .github/workflows/*.yml .github/workflows/*.yaml; do
  [ -e "$f" ] || continue
  found=1
  echo "$f"
  grep -hE '^[[:space:]]*(-[[:space:]]*)?uses:' "$f" | sed 's/^[[:space:]]*/	/'
done
[ "$found" -eq 1 ] || echo "(none)"
echo "==> this repo: tasks"
grep -oE '^\[[a-z0-9:_-]+\]' .mise/tasks.toml 2>/dev/null | tr -d '[]' | tr '\n' ' ' | sed 's/ $//' | grep . || echo "(none)"

prompt next >&2
