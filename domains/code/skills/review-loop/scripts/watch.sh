#!/usr/bin/env bash
# Wait until the automation on a PR has settled, then print the state to act on:
# the head SHA, each check's state, the reviewer's latest verdict, and the active threads.
# Settled means no check is pending and the head has not moved across two polls.
# usage: watch.sh <pr-number-or-url> [--interval <seconds>] [--timeout <minutes>]
set -euo pipefail

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
echo "==> checks"
gh pr checks "$pr" --json name,bucket --jq '.[] | "\(.bucket)\t\(.name)"' 2>/dev/null || echo "(none)"
echo "==> verdict"
gh pr view "$pr" --json comments --jq '[.comments[] | select(.body | test("(^|\n)Verdict: "))] | last | if . == null then "(no verdict yet)" else "\(.author.login) \(.createdAt)\n\(.body | capture("(?<v>Verdict: [^\n]*)").v)" end'
.agents/refs/review-threads.sh "$pr" --active
