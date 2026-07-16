---
name: create-skill
description: Scaffold a new skill next to the existing ones. Use when the user wants to create a new skill / command for their workflow — game or writing (e.g. "新しいskillを作って", "create-skill", "○○するskillが欲しい").
---

Run `.agents/skills/create-skill/refs.sh` — it prints this repo's **domain** (game or story),
that domain's create-skill conventions, and the house rules for writing LLM-facing
instructions. Follow all of them; the domain conventions below are "the loaded rules".

## Locate the skill root — don't assume a path

This runs in two kinds of place:

- **A repo that consumes the kit** — existing skills are symlinked into `.agents/skills/<name>/`.
  Create the new skill there. Never write under `.claude/skills` — its entries are symlinks.
- **The skill-kit repo itself** — skills live at `domains/<domain>/skills/<name>/` (domain-specific,
  the usual case) and `shared/skills/<name>/` (only when the skill is genuinely useful to *both*
  domains, like `setup`). Put a domain-specific skill under `domains/<domain>/skills/`; reach for
  `shared/skills/` only when it truly spans both.

Run `ls .agents/skills/ domains/*/skills/ shared/skills/ 2>/dev/null` and use whichever already
holds the existing skills as the root. List it; if a similar skill exists, refine it instead of
adding a near-duplicate.

## Write it

The user supplies the skill name, what it does, and its trigger. Name it lowercase, dashed,
verb-like (`fix`, `logs`, `dupcheck`, `block-breaks`). Write `<skill-root>/<name>/SKILL.md` — YAML
frontmatter with `name` and `description` (the description carries the trigger phrases, since
that's what surfaces the skill), then the body. Writing it triggers the house rules for LLM-facing
instructions; follow them, and follow the domain conventions from the loaded rules. Match the
voice of the existing skills: what the skill does, the pitfalls, the steps.

## Finish

If the new skill was created under a consuming repo's `.agents/skills/`, run `skill-kit sync`
(no domain needed — it reuses the recorded one) so it is linked into `.claude/skills/`. In the
skill-kit repo itself no sync is needed — the deployer links skills at `sync` time. Then run
`git status` to confirm only the new skill directory changed.
