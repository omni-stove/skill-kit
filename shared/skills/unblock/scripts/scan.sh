#!/usr/bin/env bash
# Find the open issues filed to wait (delegate's `待ち: #n ...` and `ラベル: `<label>`` body
# lines, no worker label yet), add the label to each one whose waits are all closed as completed,
# and print one line per waiting issue as <state><TAB><number><TAB><label><TAB><title><TAB><url><TAB><waits>:
#   labeled  every wait completed; the label was added now
#   waiting  a wait is still open; <waits> lists the open ones
#   dropped  no wait is open but one closed as not planned; <waits> lists those
#   scan.sh                       scan every waiting issue
#   scan.sh --force <number>...   add the label to these waiting issues whatever their waits
set -euo pipefail
. "$(dirname -- "$0")/../../../refs/prompt.sh"

usage() { echo "usage: scan.sh | scan.sh --force <number>..." >&2; exit 2; }
force=
if [ "${1:-}" = "--force" ]; then
  shift
  [ $# -ge 1 ] || usage
  for n in "$@"; do [[ "$n" =~ ^[0-9]+$ ]] || usage; done
  force=" $* "
else
  [ $# -eq 0 ] || usage
fi

waiting="$("${GH_CMD:-gh}" issue list --state open --limit 500 --json number,title,labels,body,url \
  --jq '.[] | select(([.labels[].name] | index("bug") or index("implementation")) | not)
         | ([(.body // "") | capture("ラベル: `(?<t>bug|implementation)`")? | .t] | first) as $t
         | ([(.body // "") | capture("待ち: (?<w>[^\n]*)")? | .w] | first) as $w
         | select($t != null and $w != null)
         | "\(.number)\t\($t)\t\(.title)\t\(.url)\t\($w)"')"

while IFS=$'\t' read -r number label title url waits; do
  [ -n "$number" ] || continue
  if [ -n "$force" ]; then
    case "$force" in *" $number "*) ;; *) continue ;; esac
    state=labeled
    left=
    force="${force/ $number / }"
  else
    open=
    dropped=
    for w in $waits; do
      n="${w#\#}"
      [[ "$n" =~ ^[0-9]+$ ]] || continue
      s="$("${GH_CMD:-gh}" issue view "$n" --json state,stateReason --jq '"\(.state) \(.stateReason)"')"
      case "$s" in
        OPEN*) open="$open #$n" ;;
        "CLOSED COMPLETED") ;;
        *) dropped="$dropped #$n" ;;
      esac
    done
    if [ -n "$open" ]; then state=waiting; left="${open# }"
    elif [ -n "$dropped" ]; then state=dropped; left="${dropped# }"
    else state=labeled; left=; fi
  fi
  [ "$state" = labeled ] && "${GH_CMD:-gh}" issue edit "$number" --add-label "$label" >/dev/null
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$state" "$number" "$label" "$title" "$url" "$left"
done <<< "$waiting"
if [ -n "$force" ]; then
  [ -z "${force// /}" ] || { echo "scan: not a waiting issue:${force% } — run scan.sh to list them" >&2; exit 1; }
else
  prompt scan >&2
fi
