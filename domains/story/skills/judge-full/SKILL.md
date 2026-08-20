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

Collect the results into a first-round tally: each judge's verdict in one line, and where the judges agreed and where they split — on the verdict and on individual points.

If anything split, run a discussion round: send each judge, via SendMessage, the other judges' verdicts and reasoning on the split points, with the task to rebut or concede each point and restate their verdict — changing it is allowed. Run further rounds only while a verdict is still changing. Then run `.agents/skills/judge-full/scripts/save.sh <manuscript-path> discussion '<each judge's statement per round, verbatim>'`.

Output the first-round tally, then the final vote count (N/M) with the overall verdict, each judge's final verdict in one line noting any change, what the discussion settled, and what stayed split.

Run `.agents/skills/judge-full/scripts/save.sh <manuscript-path> report '<that output>'`.
