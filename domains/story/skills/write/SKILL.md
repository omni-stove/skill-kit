---
name: write
description: Write story content by specifying a project. Use when the user wants to draft a story scene/chapter from a memo or work-in-progress file for a given project id.
---

Run `.agents/skills/write/refs.sh`

The user provides the project-id and a file path (the memo or work-in-progress file).

Get each path from `.agents/refs/path <project-id> <what> [name]`; never hand-build one. `<what>`: `story_memo` (takes a memo filename) and `story_body_file` (takes a chapter name).

1. **Resolve and Read**
   - `memo/[filename].md` → the `story_memo` path; `[chapter].md` → the `story_body_file` path; full path as-is
   - Output `Starting work: <resolved path>`, then read the file

2. **Create or Resume File**
   - Extract the leading number from the source filename and output as `[number].txt`
   - If a work-in-progress file exists: read it, ask "Continue from where you left off, or start over?", wait for response

3. **Re-read Memo Section**
   - Before writing each Scene, re-read only that Scene's section from the memo
   - Quote the relevant memo section in your response before writing

4. **Write**
   - Add metadata at the top (include `POV:` only if the project specifies a POV character):

     ```
     Memo: memo/[filename].md
     POV: <character name>
     ```

   - Write 1 Scene following the loaded format, style, and rhythm rules

5. **Hand Off**
   - After 1 Scene, output the file and hand off:

     ```
     [Scene name] complete. Say continue for the next Scene, or tell me what to revise.
     ```

   - Wait for user signal.

6. **Next Scene Confirmation**
   - User continues → return to step 3 for the next Scene
   - User requests narration revision → revise directly without re-reading

Constraints:

- Memo file is the primary source
- Other files (character, world, adjacent chapters, plot) may be read for consistency
