---
name: remote-issue
description: Split a task too large for one session into independent issues labeled bug, prototype or implementation, under one parent issue, so the issue worker implements them in parallel. Takes the task description. Use when the user wants work handed to the remote agent as issues (e.g. "remote-issue", "Issue に分割して投げて", "これを自動実装に回して").
---

Take the task from the argument and the decisions already made in the conversation. Settle an open point yourself and write the choice into the issue body.

Split the task into issues that can be implemented independently and in parallel. Leave out an issue that depends on another's result; it is filed after that PR merges, and goes in the parent's checklist.

Label each issue by what it is: `bug` fixes existing behavior, `prototype` is a mock-level trial that becomes a draft PR, `implementation` is production quality with real data access, error handling and tests. Size an `implementation` issue to about an hour of work and the others to about half an hour.

Write a body the worker can start from alone: the expected behavior and the done condition, the files and functions to start at (found with Grep), and the existing code to follow.

Run `gh issue list --search "<keywords>" --state open` and read what is similar. An open issue with one of the three labels that already covers an item replaces that item; name it in the report. Link other similar issues from the parent's body.

Run `.agents/skills/remote-issue/scripts/parent.sh "<title>" "<body>"`, or `.agents/skills/remote-issue/scripts/parent.sh --issue <number> "<body>"` when the conversation points at an existing issue as the task's origin. The body holds the goal, the decisions, how the work was split, and the checklist of deferred items.

Run `.agents/skills/remote-issue/scripts/create.sh --parent <number> <bug|prototype|implementation> "<title>" "<body>"` per issue.

Report the parent's URL, each issue's label and one-line summary, the deferred items, and the existing issues that replaced items.
