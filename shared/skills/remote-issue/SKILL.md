---
name: remote-issue
description: Split a task too large for one session into independent issues labeled bug or implementation, under one parent issue, so the issue worker implements them in parallel. Takes the task description. Use when the user wants work handed to the remote agent as issues (e.g. "remote-issue", "Issue に分割して投げて", "これを自動実装に回して").
---

Take the task from the argument and the decisions already made in the conversation. Settle an open point yourself and write the choice into the issue body.

Split the task into issues that can be implemented in parallel. An issue that depends on another's result waits on it, and is filed now too.

Label each issue: `bug` fixes existing behavior, `implementation` is new work at production quality with real data access, error handling and tests. Size an `implementation` issue to about an hour of work, a `bug` to about half an hour.

Write a body the worker can start from alone: the expected behavior and the done condition, the files and functions to start at, and the existing code to follow.

Run `.agents/skills/remote-issue/scripts/similar.sh <keywords from the task>...`

Run `.agents/skills/remote-issue/scripts/parent.sh "<title>" "<body>"`, or `.agents/skills/remote-issue/scripts/parent.sh --issue <number> "<body>"` when the conversation points at an existing issue as the task's origin. The body holds the goal, the decisions, and how the work was split.
