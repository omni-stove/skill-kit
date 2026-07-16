---
name: create-pr
description: Check git changes and create a Pull Request. Use when the user wants to review their git changes and open a GitHub PR, optionally specifying a base branch.
---

The user may optionally specify the base branch name (default: main).

Run `git status` for changed files, `git diff` for the changes, and `git log` for recent commit messages (style reference).

Identify the change type (feature, bug fix, refactoring, docs, etc.), the impact scope, and the key changes.

Generate the PR title from the changes. Create the PR body with a Summary (1-3 bullet points) and a Test plan (checklist for testing). Stage changes, create a branch, and commit if needed; push to remote; create the PR with `gh pr create`.

Display the created PR URL and confirm the PR state.

- Perform only history-preserving operations
- Keep remote branches
- Follow existing commit message style
- Include "🤖 Generated with [Claude Code](https://claude.com/claude-code)" in the PR body

Requires GitHub CLI, a GitHub-hosted repository, and configured authentication.
