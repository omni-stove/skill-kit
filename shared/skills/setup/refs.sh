#!/bin/sh
# Load the domain-specific setup rules. Which domain this repo runs was recorded at
# `skill-kit <domain> sync` time in .agents/refs/domain; the matching setup-rules.md is
# deployed from that domain's refs. Both are read from .agents/refs, so a real override
# there wins over the kit default just like any other ref.
domain=$(cat .agents/refs/domain 2>/dev/null || echo "unknown")
echo "# domain: $domain"
echo
cat .agents/refs/setup-rules.md
