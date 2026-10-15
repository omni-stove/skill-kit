---
name: judge
description: Screen a work as a contest judge — the synopsis first, then the opening text. Use when the user asks for a contest-judge evaluation of a work.
argument-hint: <synopsis-path> <synopsis-limit> <manuscript-dir>
---

Arguments, in order: the synopsis file path, the synopsis character limit, then the manuscript directory.

Judge by the contest rules provided in this conversation. How to weigh the criteria where the rules leave it open is your call. Judge criteria that need the whole work from what the synopsis promises.

Complete each screening and output its verdict before opening anything the next one reads: **通過** or **落選**, never a conditional or middle verdict, with your reasons, quoting the text where you point at something specific.

## 梗概審査

Run `.agents/refs/synopsis.sh <synopsis-path> <synopsis-limit>`.

Pass the synopsis if it proves the story worth reading in full. Judge the story it describes — not its prose, and not what it leaves out unless the gap leaves the story's appeal unproven.

On 落選, stop here.

## 冒頭審査

Run `.agents/skills/judge/scripts/opening.sh <manuscript-dir>`
