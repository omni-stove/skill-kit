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
- Skip repetition that carries the text — a motif, a proper noun, a deliberate echo of an earlier line, emphasis, rhythm — and note it
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

After output, fix every High and Medium finding, with the whole target file read. Group the findings by the line they touch; a line named in several findings gets one rewrite that resolves all of them. Rewrite the later line of each pair, never the earlier; for a cross-file pair, the line in the later file. Where one expression runs through three or more findings, keep it at the point of highest tension and cut the other occurrences, earlier lines included.

Cut a speech, perception, thought, connective, or body-reaction tag where the line keeps its meaning without it.

Where deletion loses meaning, move the observation, not the vocabulary: attend to another sense, another detail of the same moment, or the POV's judgment of it. Carry every fact a later line refers back to, state only what the scene already contains, and keep the loaded format and style rules.

Reread each touched passage and split or merge neighbouring sentences left the same length.

Where none of this removes the overlap — the repeated element is itself a fact the text states — keep the line exactly as written and report it as 修正不可 with the reason. An intact text with findings left beats a fixed one that says something else.

Run the detection again on every edited file (for a cross-file pair, both files) and fix any High or Medium finding that remains or is new — once, under the same constraint.

Last, read each edited file whole against its diff, following it as a reader, and restore the original line wherever a fact moved or the flow broke. For a cross-file pair, read the tail of the earlier file into the head of the later one.

Report what was fixed, what remains, what was left as 修正不可, and every line restored.
