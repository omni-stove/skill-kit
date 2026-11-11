---
name: remote-issue
description: Split a task too large for one session into independent issues labeled bug, prototype or implementation, under one parent issue, so the issue worker implements them in parallel. Takes the task description. Use when the user wants work handed to the remote agent as issues (e.g. "remote-issue", "Issue に分割して投げて", "これを自動実装に回して").
---

Take the task from the argument and the decisions already made in the conversation. Settle an open point yourself and write the choice into the issue body.

Split the task into issues that can be implemented independently and in parallel. An issue that depends on another's result is filed after that PR merges and goes in the parent's checklist.

Label each issue: `bug` fixes existing behavior, `prototype` is a mock-level trial that becomes a draft PR, `implementation` is production quality with real data access, error handling and tests. Size an `implementation` issue to about an hour of work, the others to about half an hour.

Write a body the worker can start from alone: the expected behavior and the done condition, the files and functions to start at, and the existing code to follow.

Run `.agents/skills/remote-issue/scripts/similar.sh <keywords from the task>...`

Run `.agents/skills/remote-issue/scripts/parent.sh "<title>" "<body>"`, or `.agents/skills/remote-issue/scripts/parent.sh --issue <number> "<body>"` when the conversation points at an existing issue as the task's origin. The body holds the goal, the decisions, how the work was split, and the checklist of deferred items as `- [ ]` lines.
