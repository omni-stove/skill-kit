---
name: create-skill
description: Scaffold a new skill in this skill-kit repo. Use when the user wants to create a new skill / command for the kit — game or story (e.g. "新しいskillを作って", "create-skill", "○○するskillが欲しい").
---

This is the kit repo's own skill — new skills are authored here and reach consuming
repos on their next `skill-kit <domain> sync`.

Decide the domain the skill belongs to (game or story; ask if unclear), then run
`.claude/skills/create-skill/refs.sh <domain>` and follow everything it prints;
the domain conventions are "the loaded rules".

The skill lives at `domains/<domain>/skills/<name>/`; use `shared/skills/<name>/` only
when it is genuinely useful to both domains. List the target dir; if a similar skill
exists, refine it instead of adding a near-duplicate.

The user supplies the skill name, what it does, and its trigger. Name it lowercase,
dashed, verb-like (`fix`, `logs`, `dupcheck`). Write `SKILL.md` — YAML frontmatter with
`name` and `description`, then the body. Match the voice of the existing skills.

Run `git status` to confirm only the new skill directory changed.
