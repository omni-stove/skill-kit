#!/usr/bin/env bash
# Reply to one review thread, then resolve it.
# usage: reply-review-thread.sh <pr-number> <thread-id> <comment-id> <body>
# The thread id and the comment_id are the ones review-threads.sh prints in the thread's
# heading and its comment headings.
set -euo pipefail

usage() { echo "usage: reply-review-thread.sh <pr-number> <thread-id> <comment-id> <body>" >&2; exit 2; }
[ "$#" -eq 4 ] || usage
pr="$1"; thread_id="$2"; comment_id="$3"; body="$4"
[[ "$pr" =~ ^[0-9]+$ ]] || { echo "reply-review-thread: pr-number must be numeric: $pr" >&2; exit 2; }
[[ "$comment_id" =~ ^[0-9]+$ ]] || { echo "reply-review-thread: comment-id must be numeric: $comment_id" >&2; exit 2; }
[ -n "$body" ] || { echo "reply-review-thread: the body is empty" >&2; exit 2; }

"${GH_CMD:-gh}" api "repos/{owner}/{repo}/pulls/${pr}/comments/${comment_id}/replies" -f body="$body" --jq '"replied \(.id) \(.html_url)"'
"$(dirname -- "$0")/resolve-review-thread.sh" "$pr" "$thread_id"
