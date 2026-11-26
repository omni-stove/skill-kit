---
name: delegate
description: Split a task too large for one session into issues for the remote issue worker, with the steps only the user can do as manual issues.
---

Run `.agents/skills/delegate/refs.sh`

Take the task from the argument and the conversation's decisions, and settle open points yourself.

Read the code and list the files each item changes, counting the files every change appends to.

Split it into issues that touch disjoint files, each holding as much as one agent session can read, change and verify. When lists share a file, start with an `implementation` issue that, without changing behavior, makes the changes to the shared files, splits files later issues would edit in the middle, and adds the types and extension points they plug into. For new behavior, keep the issues off existing entry points and end with an `implementation` issue that wires them in and checks the whole path. An issue waits on every issue whose files or results it needs, and is filed now too.

Label each issue `bug`, which fixes existing behavior, or `implementation`, which is new work at production quality with real data access and tests. Write the task as what to do and the check as how a person confirms it by hand, following the loaded rules.

Split the other issues so each runs without the user. Add one `manual` issue whose task is, in the order the user does them, every step only the user can do on their machine, by hand or with computer use, and the checks of the other issues; its check is how the user confirms the whole task works.

Run `.agents/skills/delegate/scripts/similar.sh <keywords from the task>...`

Run `.agents/skills/delegate/scripts/parent.sh --issue <number> "<body>"` with the issue the conversation points at as the task's origin, or `.agents/skills/delegate/scripts/parent.sh "<title>" "<body>"` when there is none. The body holds the goal, the decisions, and the split with the files each issue changes.
