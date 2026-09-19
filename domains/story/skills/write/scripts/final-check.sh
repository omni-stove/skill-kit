#!/bin/sh
# Usage: final-check.sh
# Prints the checks to run over the whole output file once its last Scene is written.
cat <<'EOF'
Read the whole output file and fix each hit in place; you judge what is a hit.

- Cut a sentence that rewords the one before it, or recaps what the text has already shown.
- Rewrite, from what is known at that point, narration or dialogue that draws on an answer the story gives only later.
- Restore a dropped object, subject, referent, or action where the lines before it do not supply it.
- Where the same wording appears twice, keep one; a deliberate echo stays.
EOF
