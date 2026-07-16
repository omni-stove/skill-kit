# Repetition Check — Shared Rules

## Detection Targets

Detect semantic, action, and descriptive overlap, not mere lexical matches:

- Same action / body movement
- Same emotion / reaction
- Same description / atmosphere
- Same gaze / attention
- Same thought / internal monologue with same content

## Detection Rules

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

Edit the target file(s) to resolve each selected repetition: rewrite one side of the pair to remove the semantic overlap while preserving meaning.
