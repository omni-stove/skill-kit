## Scene Boundary

A "scene" is bounded by:

- Blank lines (one or more consecutive empty lines)
- Section markers (◇, ＊, ※, ──, ---, etc.)
- Explicit time/place shifts in narration

Define scenes first, then evaluate and report each independently.

## Detection Targets

### 1. White Room — 空間描写の欠落

A scene contains dialogue/action but lacks anchoring description of:

- Place (room type, indoor/outdoor, landmark)
- Lighting / time of day
- Spatial layout (relative positions, what's nearby)

Flag a scene as 🔴 White Room if **none** of the above appear in the entire scene. Flag as 🟡 if only one anchor appears for a long scene.

### 2. Disembodied Speech — 無手・無足

A run of consecutive dialogue lines without any narration of:

- Body movement, gesture, facial expression
- Posture, position, facing direction
- Held objects or interaction with surroundings

Threshold: **6+ consecutive dialogue lines** with no physical action narration → 🔴. **4-5 lines** → 🟡.

### 3. Sensory Imbalance — 五感の偏り

A scene relies almost entirely on visual description. No mention of:

- Sound (ambient noise, voices, footsteps)
- Smell, taste
- Touch, temperature, texture
- Bodily sensation (weight, balance, fatigue)

Flag 🟡 if the scene is long (50+ lines) with only visual cues. 🔴 if no non-visual cue appears in a scene of 100+ lines.

### 4. POV Deviation — 視点の逸脱

In a first-person or close third-person scene, flag:

- POV character's own face/expression described from outside (e.g. 「私は驚いた顔をした」 in first-person)
- Internal thoughts/feelings of non-POV characters stated as fact
- Information the POV character cannot perceive (events in another room, etc.)

### 5. Silent Character — 沈黙の登場人物

Multiple named characters are established as present, but one or more receive no dialogue, action, or reaction over an extended stretch (40+ lines). They become invisible despite being in the scene.

### 6. Time Elasticity — 時間の伸縮

- Long internal monologue or extensive dialogue framed as instantaneous (e.g. happening during a single sword stroke without acknowledgment)
- Rapid narration glossing over hours/days within a scene that should be continuous
- Mismatch between volume of conversation and the time the scene allows

### 7. Name Fluctuation — 呼称の揺れ

Within a single scene, the same character is referred to by inconsistent names/titles in the narration (not in dialogue) without in-story reason.

### 8. Reader-Aimed Exposition — 読者への過剰説明

Characters explain to each other information both clearly already know, with no in-fiction motivation. Phrasing aimed at the reader rather than the interlocutor.

### 9. Topic Jump in Paragraph — 段落内話題跳躍

A single paragraph contains multiple unrelated topics or scene elements that should be split into separate paragraphs.

### 10. Distance / Action Mismatch — 距離と動作の不整合

Action implies physical contact or proximity inconsistent with the established distance between characters (e.g. touching someone described as standing across the room).

## Detection Rules

- Skip and note when an issue is clearly intentional (stylistic choice, rapid-fire exchange, dream sequence, etc.).
- Flag short scenes (under 20 lines) for White Room or Sensory Imbalance only when the lack is conspicuous.
- Use line numbers for the start of each scene and each finding.

## Output Format

```markdown
# Scene Staging Check

## Target
[file path]

## Results

### Scene 1 (L[start]-L[end]) — [brief one-line scene description]

- 🔴 [Category] (L[N]): [detail]
- 🟡 [Category] (L[N]): [detail]

### Scene 2 (L[start]-L[end]) — [brief description]

- ✅ No issues

### Scene 3 ...

## Summary

| Category | 🔴 | 🟡 |
|----------|----|----|
| White Room | N | N |
| Disembodied Speech | N | N |
| Sensory Imbalance | N | N |
| POV Deviation | N | N |
| Silent Character | N | N |
| Time Elasticity | N | N |
| Name Fluctuation | N | N |
| Reader-Aimed Exposition | N | N |
| Topic Jump | N | N |
| Distance Mismatch | N | N |
```

Severity:

- 🔴 **Critical**: Severe lack of essential scene anchoring, clear POV break, obvious time/distance contradiction
- 🟡 **Minor**: Partial lack or borderline issue that may be acceptable in context

Output the report and stop: report findings mechanically — no `AskUserQuestion`, no fixes.
