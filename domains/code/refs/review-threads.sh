#!/usr/bin/env bash
# List the review threads of a PR with their thread ids, one heading per thread:
#   ### <thread-id> <path>:<line> [active|resolved|outdated]
# followed by its comments. The thread id is what resolve-review-thread.sh takes.
# usage: review-threads.sh [pr-number] [--active|--all|--resolved|--outdated]
# Default is --active: unresolved threads that still point at current code.
# No pr-number resolves the PR of the current branch.
set -euo pipefail

usage() { echo "usage: review-threads.sh [pr-number] [--active|--all|--resolved|--outdated]" >&2; }

mode="active"
pr=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --active) mode="active" ;;
    --all) mode="all" ;;
    --resolved) mode="resolved" ;;
    --outdated) mode="outdated" ;;
    -h|--help) usage; exit 0 ;;
    --*) usage; exit 2 ;;
    *) [ -z "$pr" ] || { usage; exit 2; }; pr="$1" ;;
  esac
  shift
done
if [ -n "$pr" ] && ! [[ "$pr" =~ ^[0-9]+$ ]]; then
  echo "review-threads: pr-number must be numeric: $pr" >&2
  exit 2
fi
if [ -z "$pr" ]; then
  pr="$("${GH_CMD:-gh}" pr view --json number -q .number)"
  echo "==> resolved PR from current branch: #$pr"
fi
owner="$("${GH_CMD:-gh}" repo view --json owner -q .owner.login)"
repo="$("${GH_CMD:-gh}" repo view --json name -q .name)"

case "$mode" in
  active) jq_filter='select(.isResolved == false and .isOutdated == false)' ;;
  all) jq_filter='select(true)' ;;
  resolved) jq_filter='select(.isResolved == true)' ;;
  outdated) jq_filter='select(.isOutdated == true)' ;;
esac

read -r -d '' jq_expr <<JQ || true
[
  .data.repository.pullRequest.reviewThreads.nodes[]?
  | ${jq_filter}
  | . as \$t
  | "### \(\$t.id) \(\$t.path):\(\$t.line // \$t.originalLine // "file") [\(if \$t.isResolved then "resolved" elif \$t.isOutdated then "outdated" else "active" end)]\n"
    + "- canResolve: \(\$t.viewerCanResolve)\n"
    + (if \$t.resolvedBy.login then "- resolvedBy: @\(\$t.resolvedBy.login)\n" else "" end)
    + "\n"
    + (\$t.comments.nodes | map("#### @\(.author.login) (\(.createdAt)) [comment_id=\(.databaseId)]\n\(.body)\n") | join("\n"))
]
| join("\n\n")
JQ

echo "==> review threads (${mode}) for #${pr}"
# shellcheck disable=SC2016
"${GH_CMD:-gh}" api graphql --paginate -f query='query($owner:String!,$repo:String!,$pr:Int!,$endCursor:String){
  repository(owner:$owner,name:$repo){
    pullRequest(number:$pr){
      reviewThreads(first:100,after:$endCursor){
        pageInfo{hasNextPage endCursor}
        nodes{
          id isResolved isOutdated viewerCanResolve path line originalLine
          resolvedBy{login}
          comments(first:100){ nodes{ databaseId author{login} body createdAt } }
        }
      }
    }
  }
}' -f owner="${owner}" -f repo="${repo}" -F pr="${pr}" --jq "$jq_expr"
