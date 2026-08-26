# Repetition Check — Shared Rules

## Detection Targets

Detect semantic, action, and descriptive overlap, not mere lexical matches:

- Same action / body movement
- Same emotion / reaction
- Same description / atmosphere
- Same gaze / attention
- Same thought / internal monologue with same content

## Detection Rules

- Quote each expression exactly as written in the file — a contiguous, unparaphrased substring
- Report only narration; leave anything inside dialogue quotes (「」『』) out of the results
- Skip intentional repetition (emphasis, rhythm) and note it
- Treat within-sentence repetition as rhetorical and ignore it

## Output Format

```markdown
# Repetition Check

## Target
[file path(s)]

## Results

### High
#### 1. [Category (e.g. same action)]
- **L[line]**: 「[expression A]」
- **L[line]**: 「[expression B]」
- **Distance**: [X] lines

### Medium
#### 1. ...

### Low
#### 1. ...
```

Severity criteria:
- **High**: same meaning within the same scene or nearby passage; readers will notice
- **Medium**: same meaning across different scenes; noticeable on attentive reading
- **Low**: lower semantic similarity, or separated by significant distance

For cross-file pairs, prefix each line with its file name (e.g. `**010.txt L42**`) and set Distance to `cross-file`.

## Fix Flow

After output, ask via `AskUserQuestion`: 「修正する項目を選んでください」 — options (multiSelect, max 4): 「すべて修正（深刻度: 高・中）」 first, then the top 3 high-severity items in priority order.

Edit with the whole target file read. Group the selected findings by the line they touch; a line named in several findings gets one rewrite that resolves all of them. Rewrite the later line of each pair, never the earlier — a text leans forward on what it has already put on the page; for a cross-file pair, that is the later file.

The rewrite substitutes wording, never content. Carry every fact of the original line into the new one — what it describes, the sense it is perceived through, whether it acts or thinks, each detail it names, and whatever a later line refers back to — and keep its place in the flow, its length, and the loaded format and style rules.

Delete a line only where an earlier line already states its fact, and delete it whole.

Where wording alone cannot remove the overlap — the repeated element is itself a fact the text states — keep the line exactly as written and report it as 修正不可 with the reason. A finding that ends here is the flow working: an intact text with findings left beats a fixed one that says something else.

Run the detection again on every edited file (for a cross-file pair, both files) and fix any High or Medium finding that remains or is new — once, under the same constraint.

Last, read each edited file whole against its diff, following it as a reader, and restore the original line wherever a fact moved or the flow broke. For a cross-file pair, read the tail of the earlier file into the head of the later one.

Report what was fixed, what remains, what was left as 修正不可, and every line restored.
