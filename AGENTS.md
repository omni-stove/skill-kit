Edit an LLM-facing instruction file by `shared/refs/llm-instruction-rules.md`: read it before the edit, and check each changed line against it after.

In a script's header comment, state what the script does, its arguments and its output. In any other comment, state only why the straightforward alternative was not taken, or the constraint that binds the code. Delete a comment that restates the implementation, also in code you did not write.

When you add a skill, or change what the user meets in one — its branches, what the user is asked, what the user gets — make `README.md` and `README.ja.md` beside its `SKILL.md` the skill name and a flowchart of those alone, in the shape of `domains/story/skills/write/README.md`. Leave out what the user cannot observe from outside the skill and the rules the skill follows when writing its output.
