---
name: judge-full
description: Full manuscript review as a contest final judge. Evaluate whether this work deserves the grand prize. Use when the user asks for a full-manuscript final-round judgment of a complete work.
argument-hint: <synopsis-path> <manuscript-path> [judges]
---

Arguments, in order: the synopsis file path, the manuscript file path, and optionally the number of judges (default: 3).

Never read the synopsis or manuscript yourself; pass only the file paths to the judges.

Spawn the judge-count number of agents in parallel with the Agent tool. Each judge's prompt contains:

- The synopsis and manuscript file paths, with the instruction to read both in full
- The contest rules and any notes from this conversation, embedded verbatim
- The task: as a final-round judge, decide **大賞 / 大賞ではない** and give the reasons, quoting the text. How to weigh the criteria is the judge's own call.

Collect the results and output the vote count (N/M) with the overall verdict, each judge's verdict in one line, and where the judges agreed and where they split.

Run `.agents/skills/judge-full/scripts/save.sh <manuscript-path> '<that output>'`.
