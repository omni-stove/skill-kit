---
name: digest-through
description: Read each file in the target directory sequentially and output a plain-prose digest per file. Use when the user wants a file-by-file factual digest of every file in a directory, processed one at a time.
---

The user provides a file path. The digest covers every file in that file's directory.

List files in that directory, natural sort, skip synopsis.

Loop sequentially: Read 1 file → write digest (who, what happens, ending state; plain prose, no headings, no bullet templates, no evaluation) → Read next file → write digest → ... Never batch reads, never parallel. Do not end the turn until every file has been processed.

Use only what the file itself shows. Do not consult project settings, character files, or world docs.

If a later file reveals an earlier digest was wrong, add a one-line correction naming the earlier file and what changed. Don't rewrite the original digest.

After all files are done, output an overall understanding of the directory — through-line, main characters, what the story is doing — in plain prose, reflecting any corrections.
