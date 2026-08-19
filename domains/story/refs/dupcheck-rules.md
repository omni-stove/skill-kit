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
- Distinguish dialogue from narration
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

Edit with the whole target file read. Group the selected findings by the line they touch; a line named in several findings gets one rewrite that resolves all of them. Rewrite one side of each pair to remove the semantic overlap while preserving meaning and the surrounding rhythm. For a cross-file pair, rewrite only one side.

After editing, run the detection again on every edited file (for a cross-file pair, both files) and fix any High or Medium finding that remains or is new — once. Then report what was fixed and what remains.
