---
name: dupcheck
description: Detect semantically overlapping expressions within a single Japanese fiction text file. Use when the user asks to check a story file for 重複表現 / repeated expressions / repetition in close proximity, and names one file (e.g. "重複チェックして", "dupcheck this file").
---

Run `.agents/skills/dupcheck/refs.sh`

The user specifies one target file path. If no path is given, ask which file to check.

Read the entire target file and detect expressions that overlap in meaning or action within close proximity, across the whole file — apply the loaded rules exactly, following their Detection Targets, Detection Rules, severity criteria, Output Format, and Fix Flow (ask the user whether to fix, then apply selected edits).
