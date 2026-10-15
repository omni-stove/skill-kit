#!/bin/sh
# Print the create-skill conventions for one domain, then the house rules that
# writing any LLM-facing instruction must follow. $1 = game|story|code.
cat ".claude/skills/create-skill/refs/${1:?usage: refs.sh game|story|code}.md"
echo
cat shared/refs/llm-instruction-rules.md
