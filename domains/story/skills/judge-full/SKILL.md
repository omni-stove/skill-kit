---
name: judge-full
description: Full manuscript review as a contest final judge. Evaluate whether this work deserves the grand prize. Use when the user asks for a full-manuscript final-round judgment of a complete work.
argument-hint: <synopsis-path> <synopsis-limit> <manuscript-path> [judges]
---

Arguments, in order: the synopsis file path, the synopsis character limit, the manuscript file path, and optionally the number of judges (default: 3).

Never read the manuscript yourself; pass only its file path to the judges.

Run `.agents/refs/synopsis.sh <synopsis-path> <synopsis-limit>`.

Spawn judge-count agents in parallel with the Agent tool, each on a different model, strongest first, labeled Judge A, B, C… in that order. Each judge's prompt contains:

- The synopsis.sh output, embedded verbatim
- The manuscript file path, with the instruction to read it in full
- The tool limit: use only Read
- The contest rules and any notes from this conversation, embedded verbatim
- The task: as a final-round judge of a contest that awards the 大賞 alone, decide **大賞 / 大賞ではない** and give the reasons, quoting the text. How to weigh the criteria where the rules leave it open is the judge's own call.

Collect the results into a first-round tally: each judge's label and verdict in one line, and where the judges agreed and split — on the verdict and on individual points. Output the tally and run `.agents/skills/judge-full/scripts/save.sh <manuscript-path> first-round '<the tally>'`.

If anything split, run a discussion round: send each judge, via SendMessage, the other judges' verdicts and reasoning on the split points, attributed by label only, never by model, with the task to rebut or concede each point and restate their verdict — changing it is allowed. After each round, output the verdicts and what moved and run `.agents/skills/judge-full/scripts/save.sh <manuscript-path> discussion-<round number> '<each judge's statement, verbatim>'`. Run further rounds only while a verdict is still changing.

Output the final vote count (N/M) with the overall verdict — 大賞 when more than half the judges vote 大賞, otherwise 大賞ではない — each judge's label and final verdict in one line noting any change, what the discussion settled, and what stayed split, and run `.agents/skills/judge-full/scripts/save.sh <manuscript-path> report '<that output>'`.
