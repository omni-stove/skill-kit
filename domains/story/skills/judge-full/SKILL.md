---
name: judge-full
description: Decide by a panel of final-round contest judges whether a complete manuscript wins the 大賞, with discussion rounds where they split. Use when the user asks for a full-manuscript final-round judgment of a complete work.
argument-hint: <synopsis-path> <synopsis-limit> <manuscript-path> [judges]
---

Arguments, in order: the synopsis file path, the synopsis character limit, the manuscript file path, and optionally the number of judges (default: 3).

Never read the manuscript yourself. Feed every save.sh call its report on stdin through a quoted heredoc (`<<'EOF'`).

Run `.agents/refs/synopsis.sh <synopsis-path> <synopsis-limit>`.

Spawn judge-count agents in parallel, each on a different model, strongest first, labeled Judge A, B, C… in that order. Each judge's prompt contains:

- The synopsis.sh output, embedded verbatim
- The manuscript file path, with the instruction to read it in full
- The tool limit: use only Read
- The contest rules and any notes from this conversation, embedded verbatim
- The task: as a final-round judge of a contest that awards the 大賞 alone, decide **大賞** or **大賞ではない**, never a conditional or middle verdict, and give the reasons, quoting the text. How to weigh the criteria where the rules leave it open is the judge's own call.

Output the first-round tally — each judge's label and verdict in one line, and where the judges agreed and split, on the verdict and on individual points — and run `.agents/skills/judge-full/scripts/save.sh <manuscript-path> first-round` with it.
