---
name: split-plot
description: Split a single source file into individual plot skeleton files per scene/section. Use when the user has a long plot draft, scenario memo, or outline and wants it broken into one plot skeleton file per scene (e.g. "プロットを分割して", "split this outline into plot files").
---

Run `.agents/skills/split-plot/refs.sh`

The user provides a source file path (long plot draft, scenario memo, outline, etc.).

Read the source file, then `README.md` for world context, plus existing character and setting files relevant to the source.

Detect section boundaries — try the following splitters in order and pick the one that yields a meaningful structure:

- Markdown headings (`##`, `###`)
- Horizontal rules (`---`, `***`)
- Top-level bullet items (`- `, `* `, `1. `)
- Blank-line-separated paragraph blocks
- Explicit scene markers (e.g., `# シーン1`, `【場面X】`, `■`)

For each detected segment, capture its index (sequential), title (first heading or first sentence as a short label), and body.

Show the extracted segments to the user as a numbered list (index, title, brief body summary), and use AskUserQuestion to confirm: which splitter to use (if multiple are viable), segments to skip / merge / further split, and the base name for files.

Run `.agents/skills/split-plot/scripts/paths.sh <base> <title>...` with one short kebab-case English title per confirmed segment, in order — it prints each segment's output path. Create each plot file at its printed path.

Content: rewrite the segment as a plot skeleton based on the loaded plot format, the project's world setting, and character information. Do NOT copy the source verbatim — restructure into the plot skeleton style. Preserve any concrete narrative or dialogue worth keeping in the 地の文 / 会話 sections, pulling those lines from the source file when present — do not invent new lines. Aim for 3-8 paragraphs per file depending on segment density. Cross-reference adjacent segments to ensure continuity (how the scene begins from the previous, how it leads to the next). For the plot body, 地の文, 会話, and 参照 sections, always apply the loaded plot format rules exactly.

After generating all files, present a summary list of created files and ask if any need adjustment or further splitting/merging.
