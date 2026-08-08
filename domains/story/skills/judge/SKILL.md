---
name: judge
description: Evaluate a work as a contest judge, judging synopsis first and then opening text. Use when the user asks for a contest-judge evaluation of a work (synopsis screening then opening-text screening).
argument-hint: <synopsis-path> <manuscript-dir>
---

Arguments, in order: the synopsis file path, then the manuscript directory.

Judge by the contest rules provided in this conversation. How to weigh the criteria and what to say about the work is your call as a judge.

Read only what the current step needs.

## Step 1: 梗概審査

Read the synopsis.

A synopsis exists to prove the story is worth reading in full. Judge the story it describes — brevity and compression are its nature, so do not critique it as prose.

State a verdict — **通過 / 当落 / 落選** — and your reasons, quoting the synopsis where you point at something specific.

落選 → stop here. Otherwise proceed.

## Step 2: 冒頭審査

Run `.agents/skills/judge/scripts/opening.sh <manuscript-dir>` — it prints the manuscript's opening files, about 15,000 characters' worth. Read them in order.

Judge whether this opening survives a first-round screening against hundreds of submissions. State a verdict — **通過 / 当落 / 落選** — and your reasons, quoting the text where you point at something specific.

- **通過**: passes the first round
- **当落**: borderline; depends on the field
- **落選**: cannot pass as is
