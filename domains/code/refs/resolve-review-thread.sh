#!/usr/bin/env bash
# Resolve one review thread after checking it belongs to the given PR of this repo.
# usage: resolve-review-thread.sh <pr-number> <thread-id>
# The thread id is the one review-threads.sh prints in the thread's heading.
set -euo pipefail

usage() { echo "usage: resolve-review-thread.sh <pr-number> <thread-id>" >&2; }
[ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ] && { usage; exit 0; }
[ "$#" -eq 2 ] || { usage; exit 2; }
pr="$1"
thread_id="$2"
[[ "$pr" =~ ^[0-9]+$ ]] || { echo "resolve-review-thread: pr-number must be numeric: $pr" >&2; exit 2; }
if [ -z "$thread_id" ] || [[ "$thread_id" =~ [[:space:]] ]]; then
  echo "resolve-review-thread: thread-id must be a single non-empty value" >&2
  exit 2
fi

owner="$("${GH_CMD:-gh}" repo view --json owner -q .owner.login)"
repo="$("${GH_CMD:-gh}" repo view --json name -q .name)"

# shellcheck disable=SC2016
row="$("${GH_CMD:-gh}" api graphql -f query='query($threadId:ID!){
  node(id:$threadId){
    __typename
    ... on PullRequestReviewThread {
      isResolved viewerCanResolve path line originalLine
      pullRequest{ number repository{ name owner{login} } }
    }
  }
}' -f threadId="${thread_id}" \
  --jq 'if .data.node == null then "NOT_FOUND|||||||" else .data.node as $n
        | [$n.__typename, ($n.pullRequest.repository.owner.login // ""), ($n.pullRequest.repository.name // ""),
           (($n.pullRequest.number // "") | tostring), ($n.isResolved | tostring), ($n.viewerCanResolve | tostring),
           ($n.path // ""), (($n.line // $n.originalLine // "file") | tostring)] | join("|") end')"
IFS='|' read -r typename a_owner a_repo a_pr is_resolved can_resolve path line <<< "$row"

[ "$typename" != "NOT_FOUND" ] || { echo "resolve-review-thread: thread not found: $thread_id" >&2; exit 3; }
[ "$typename" = "PullRequestReviewThread" ] || { echo "resolve-review-thread: not a review thread: $thread_id ($typename)" >&2; exit 3; }
if [ "$a_owner" != "$owner" ] || [ "$a_repo" != "$repo" ] || [ "$a_pr" != "$pr" ]; then
  echo "resolve-review-thread: thread belongs to ${a_owner}/${a_repo}#${a_pr}, not ${owner}/${repo}#${pr}" >&2
  exit 3
fi
if [ "$is_resolved" = "true" ]; then
  echo "==> already resolved: ${thread_id} ${path}:${line}"
  exit 0
fi
[ "$can_resolve" = "true" ] || { echo "resolve-review-thread: you cannot resolve this thread: $thread_id" >&2; exit 3; }

echo "==> resolving ${thread_id} ${path}:${line}"
# shellcheck disable=SC2016
"${GH_CMD:-gh}" api graphql -f query='mutation($threadId:ID!){
  resolveReviewThread(input:{threadId:$threadId}){ thread{ id isResolved path line originalLine } }
}' -f threadId="${thread_id}" \
  --jq '.data.resolveReviewThread.thread | "resolved \(.id) \(.path):\(.line // .originalLine // "file") isResolved=\(.isResolved)"'
