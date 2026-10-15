---
name: automation
description: Install this repo's GitHub Actions automation — CI on mise + make, Claude implementing labeled issues into PRs, Claude reviewing PRs and fixing its own findings, and Claude fixing CI failures. Use when the user wants the repo's automated implementation or review workflows set up (e.g. "自動実装を入れて", "自動レビューを設定して", "automation", "issue から PR が立つようにして").
---

Run `.agents/skills/automation/scripts/install.sh`

Hand the user the commands and settings the script lists as theirs to do. Match the `workflows:` name in `.github/workflows/ci-auto-fix.yml` to the repo's CI workflow name when they differ.

Run `git status` and confirm the workflow files appear in it as real files.
