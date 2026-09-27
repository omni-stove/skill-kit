---
name: judge
description: Evaluate a work as a contest judge, judging synopsis first and then opening text. Use when the user asks for a contest-judge evaluation of a work (synopsis screening then opening-text screening).
argument-hint: <synopsis-path> <synopsis-limit> <manuscript-dir>
---

Arguments, in order: the synopsis file path, the synopsis character limit, then the manuscript directory.

Judge by the contest rules provided in this conversation. How to weigh the criteria and what to say about the work is your call as a judge. Judge criteria that need the whole work from what the synopsis promises.

Complete each step and output its verdict before opening anything the next step reads.

## Step 1: 梗概審査

Run `.agents/refs/synopsis.sh <synopsis-path> <synopsis-limit>`.

A synopsis exists to prove that the story is worth reading in full. Judge the story it describes — not its prose, and not what it leaves out unless the gap leaves the story's appeal unproven.

Output a 梗概審査 verdict — **通過 / 当落 / 落選** — and your reasons, quoting the synopsis where you point at something specific.

落選 → stop here. Otherwise proceed.

## Step 2: 冒頭審査

Run `.agents/skills/judge/scripts/opening.sh <manuscript-dir>` — it prints the manuscript's opening files, as close to 10,000 characters as the file boundaries allow. Read them in order.

Judge whether this opening survives a first-round screening against hundreds of submissions. Output a 冒頭審査 verdict — **通過 / 当落 / 落選** — and your reasons, quoting the text where you point at something specific.

- **通過**: passes the first round
- **当落**: borderline; depends on the field
- **落選**: cannot pass as is
