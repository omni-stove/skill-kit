#!/bin/sh
# Load, in order: this repo's domain, the domain's create-skill conventions, and the
# house rules that writing any LLM-facing instruction must follow. All come from
# .agents/refs, so a real override there wins over the kit default.
domain=$(cat .agents/refs/domain 2>/dev/null || echo "unknown")
echo "# domain: $domain"
echo
echo "## Domain conventions"
cat .agents/refs/create-skill-rules.md
echo
echo "## House rules (LLM-facing instructions)"
cat .agents/refs/llm-instruction-rules.md
