---
name: split-plot
description: Split a single source file into individual plot skeleton files per scene/section. Use when the user has a long plot draft, scenario memo, or outline and wants it broken into one plot skeleton file per scene (e.g. "プロットを分割して", "split this outline into plot files").
---

Run `.agents/skills/split-plot/refs.sh`

The user provides a project-id and a source file path (long plot draft, scenario memo, outline, etc.).

Resolve every project path by sourcing the layout — run `sh -c '. .agents/refs/layout.sh; <fn> <project-id>'` and use the path it prints. Never hand-build a path. Functions used here: `readme`, `story_plot` (the output dir).

Read the source file. If a project-id is given, also read the `readme` path for world context, plus existing character and setting files relevant to the source.

Detect section boundaries — try the following splitters in order and pick the one that yields a meaningful structure:

- Markdown headings (`##`, `###`)
- Horizontal rules (`---`, `***`)
- Top-level bullet items (`- `, `* `, `1. `)
- Blank-line-separated paragraph blocks
- Explicit scene markers (e.g., `# シーン1`, `【場面X】`, `■`)

For each detected segment, capture its index (sequential), title (first heading or first sentence as a short label), and body.

Show the extracted segments to the user as a numbered list (index, title, brief body summary), and use AskUserQuestion to confirm: which splitter to use (if multiple are viable), segments to skip / merge / further split, the base name for files, and the output directory (suggest the `story_plot` directory).

For each confirmed segment, create a plot file.

Filename: `NNN-[base]-[english-title].md` — NNN is a sequential three-digit number incremented by 10 (010, 020, 030...) so scenes can be inserted between existing ones later (e.g. 015 between 010 and 020); if the output directory already has numbered files, continue from the next tens number. english-title is a short kebab-case English title derived from the segment content.

Content: rewrite the segment as a plot skeleton based on the loaded plot format, the project's world setting, and character information. Do NOT copy the source verbatim — restructure into the plot skeleton style. Preserve any concrete narrative or dialogue worth keeping in the 地の文 / 会話 sections, pulling those lines from the source file when present — do not invent new lines. Aim for 3-8 paragraphs per file depending on segment density. Cross-reference adjacent segments to ensure continuity (how the scene begins from the previous, how it leads to the next). For the plot body, 地の文, 会話, and 参照 sections, always apply the loaded plot format rules exactly.

After generating all files, present a summary list of created files and ask if any need adjustment or further splitting/merging.
