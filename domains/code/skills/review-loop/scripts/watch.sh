#!/usr/bin/env bash
# Wait until the automation on a PR has settled, then print the state to act on — the head
# SHA, each check's state, the reviewer's latest verdict, the active threads, and the
# automated commits since the last human one as a diff — and what to do with it: the
# completion report when the head is clear and verified, else the fix batch.
# Settled means no check is pending and the head has not moved across two polls.
# usage: watch.sh <pr-number-or-url> [--interval <seconds>] [--timeout <minutes>]
set -euo pipefail
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"

usage() { echo "usage: watch.sh <pr-number-or-url> [--interval <seconds>] [--timeout <minutes>]" >&2; exit 2; }
pr=""; interval=45; timeout=40
while [ "$#" -gt 0 ]; do
  case "$1" in
    --interval) interval="${2:?}"; shift ;;
    --timeout) timeout="${2:?}"; shift ;;
    -*) usage ;;
    *) [ -z "$pr" ] || usage; pr="$1" ;;
  esac
  shift
done
[ -n "$pr" ] || usage
pr="$(gh pr view "$pr" --json number -q .number)"

deadline=$(( $(date +%s) + timeout * 60 ))
prev_head=""
stable=0
while :; do
  head="$(gh pr view "$pr" --json headRefOid -q .headRefOid)"
  pending="$(gh pr checks "$pr" --json bucket --jq '[.[] | select(.bucket == "pending")] | length' 2>/dev/null || echo 0)"
  if [ "$head" = "$prev_head" ] && [ "$pending" -eq 0 ]; then
    stable=$((stable + 1))
  else
    stable=0
    echo "==> head ${head:0:7}, pending checks: $pending" >&2
  fi
  [ "$stable" -ge 1 ] && break
  if [ "$(date +%s)" -ge "$deadline" ]; then
    echo "watch: automation still running after ${timeout} minutes — rerun to keep waiting, or tell the user" >&2
    exit 4
  fi
  prev_head="$head"
  sleep "$interval"
done

echo "==> head $head"
branch="$(gh pr view "$pr" --json headRefName -q .headRefName)"
head_at="$(gh pr view "$pr" --json commits --jq '.commits[-1].committedDate')"
echo "==> checks"
checks="$(gh pr checks "$pr" --json name,bucket --jq '.[] | "\(.bucket)\t\(.name)"' 2>/dev/null || echo "(none)")"
printf '%s\n' "$checks"
echo "==> verdict"
verdict_row="$(gh pr view "$pr" --json comments --jq '[.comments[] | select(.body | test("(^|\n)Verdict: "))] | last | if . == null then "" else "\(.createdAt)\t\(.author.login)\t\(.body | capture("(?<v>Verdict: [^\n]*)").v)" end')"
if [ -z "$verdict_row" ]; then
  echo "(no verdict yet)"
  verdict_at=""; verdict=""
else
  verdict_at="${verdict_row%%	*}"
  verdict="${verdict_row##*	}"
  printf '%s\n' "$verdict_row"
  [[ "$verdict_at" > "$head_at" ]] || echo "(posted before the head commit at $head_at — it is for an earlier head)"
fi
threads="$(.agents/refs/review-threads.sh "$pr" --active)"
printf '%s\n' "$threads"

# Resolved threads whose only comment is the reviewer's were resolved without a reply.
unanswered="$(.agents/refs/review-threads.sh "$pr" --resolved | awk '
  /^### /{ if (id != "" && n < 2) print id; id = $2 " " $3; n = 0; next }
  /^#### /{ n++ }
  END{ if (id != "" && n < 2) print id }')"
if [ -n "$unanswered" ]; then
  echo "==> resolved without a reply"
  printf '%s\n' "$unanswered"
fi

echo "==> automated commits since the last human commit"
git fetch -q origin "$branch"
bot_range=""
while IFS=$'\t' read -r sha author subject; do
  [ "$author" = "claude[bot]" ] || break
  bot_range="$sha"
  echo "$sha $subject"
done < <(git log --format='%H%x09%an%x09%s' "origin/$branch")
if [ -n "$bot_range" ]; then
  git --no-pager diff "${bot_range}^..origin/$branch"
else
  echo "(none)"
fi

failing="$(printf '%s\n' "$checks" | grep -c '^fail' || true)"
active="$(printf '%s\n' "$threads" | grep -c '^### ' || true)"
lgtm=0
case "$verdict" in *"Verdict: LGTM"*) [[ "$verdict_at" > "$head_at" ]] && lgtm=1 ;; esac

if [ "$lgtm" -eq 1 ] && [ "$failing" -eq 0 ] && [ "$active" -eq 0 ] && [ -z "$unanswered" ]; then
  echo "==> local state"
  local_ok=1
  [ "$(git rev-parse --abbrev-ref HEAD)" = "$branch" ] || { echo "on $(git rev-parse --abbrev-ref HEAD), not $branch — git switch $branch"; local_ok=0; }
  [ "$(git rev-parse HEAD)" = "$head" ] || { echo "local HEAD $(git rev-parse --short HEAD) is not the remote head — git pull --ff-only origin $branch"; local_ok=0; }
  [ -z "$(git status --porcelain)" ] || { echo "worktree not clean — commit or discard the changes"; local_ok=0; }
  [ "$local_ok" -eq 1 ] && echo "branch $branch at head, worktree clean"
  gh pr view "$pr" --json state,mergeable,mergeStateStatus,url --jq '"\(.state) \(.mergeable) \(.mergeStateStatus) \(.url)"'
  prompt clear >&2
else
  prompt fix pr="$pr" >&2
fi
