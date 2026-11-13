---
name: delegate
description: Split a task too large for one session into issues for the remote issue worker, with the steps only the user can do as manual issues.
---

Take the task from the argument and the decisions already made in the conversation. Settle an open point yourself.

Split the task into issues that can be implemented in parallel, each touching files no other issue touches. Open the split with an `implementation` issue that reshapes the code the rest will change without changing behavior: split the files they share, and add the types, signatures and extension points each later change plugs into, so each later issue only adds to its own files. Every other issue that changes code waits on it. When the task holds several large tasks, put what they share into that one first issue. Leave it out when the issues already touch separate files.

An issue that still touches a file another issue touches, or depends on another's result, waits on it, and is filed now too.

Label each issue: `bug` fixes existing behavior, `implementation` is new work at production quality with real data access, error handling and tests. `manual` is a step only the user can do on their own machine, by hand or with computer use. Size an `implementation` issue to about an hour of work, a `bug` to about half an hour.

Write each issue's task as what to do and its check as how a person confirms it done by hand. A `manual` issue's task is the steps the user takes.

Run `.agents/skills/delegate/scripts/similar.sh <keywords from the task>...`

Run `.agents/skills/delegate/scripts/parent.sh "<title>" "<body>"`, or `.agents/skills/delegate/scripts/parent.sh --issue <number> "<body>"` when the conversation points at an existing issue as the task's origin. The body holds the goal, the decisions, and how the work was split.
