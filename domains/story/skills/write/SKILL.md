---
name: write
description: Write story content by specifying a project. Use when the user wants to draft a story scene/chapter from a memo or work-in-progress file for a given project id.
---

Run `.agents/skills/write/refs.sh`

The user provides the project-id and a file path (the memo or work-in-progress file). Resolve the file path as described in step 2 below.

Get each path from `.agents/refs/path <project-id> <what> [name]`; never hand-build one. `<what>`: `story_memo` (takes a memo filename) and `story_body_file` (takes a chapter name).

1. **Declare Work Start**
   - Output: `Starting work: <resolved memo path>` (the `story_memo` path for the filename)

2. **Resolve File Path**
   - Convert the provided file path to a full path via the layout functions
   - `memo/[filename].md` → the `story_memo` path
   - `[chapter].md` → the `story_body_file` path
   - Use full path as-is if provided

3. **Read Source File**
   - Read the file at the resolved path

4. **Create or Resume File**
   - Extract the leading number from the source filename and output as `[number].txt`
   - If a work-in-progress file exists: read it, ask "Continue from where you left off, or start over?", wait for response

5. **Re-read Memo Section**
   - Before writing each Scene, re-read only that Scene's section from the memo
   - Quote the relevant memo section in your response before writing
   - Start from Scene 1 unless resuming or user specifies otherwise

6. **Write**
   - Add metadata at the top (include `POV:` only if the project specifies a POV character):

     ```
     Memo: memo/[filename].md
     POV: <character name>
     ```

   - Write 1 Scene following the loaded format and style rules
   - Dialogue: one `(speaker: gist)` placeholder per utterance, instead of actual `「」` text. The placeholder IS the dialogue line — adjacent to surrounding narration with no blank lines, exactly as `「」` would be
     - Gist = the utterance's intent, never its wording
   - Narration: write as prose

7. **Hand Off**
   - After 1 Scene, output the file and hand off:

     ```
     [Scene name] skeleton complete. Dialogue placeholders left as-is. Say continue for the next Scene, or tell me to fill placeholders.
     ```

   - Do not auto-fill placeholders. Wait for user signal.

8. **Next Scene Confirmation**
   - User continues → return to step 5 for the next Scene; prior placeholders stay
   - User requests narration revision → revise directly without re-reading

Constraints:

- Memo file is the primary source
- Other files (character, world, adjacent chapters, plot) may be read for consistency
- Do not recap established facts or prior events
