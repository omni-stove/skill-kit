---
name: judge
description: Evaluate a work as a contest judge, judging synopsis first and then opening text. Use when the user asks for a contest-judge evaluation of a project (synopsis screening then opening-text screening).
---

Evaluate a work as a contest judge. Judge synopsis first, then opening text. If the synopsis fails, do not proceed to the text.

The user states the project id.

Get each path from `.agents/refs/path <project-id> <what>`; never hand-build one. `<what>`: `story_synopsis`, `story_outline`, `story` (the manuscript dir). If contest rules are provided in this conversation, use them as the PRIMARY criteria; otherwise read the relevant contest-rules file under `.agents/refs/contest-rules/` (e.g. `k.md` = このミステリーがすごい!, `y.md` = 横溝正史, `h.md` = ハヤカワSF) for the contest's $CONTEST_RULES.

**Read timing**: Only read files needed for the current step. In Step 1, read ONLY the synopsis. Do NOT read story files until Step 2.

## Step 1: Synopsis Review

Read the `story_synopsis` path; if not found, check the `story_outline` directory. If neither exists, inform the author that no synopsis exists and stop.

Evaluate as a **contest judge**, NOT as a supportive editor. Be harsh but fair. Judges read hundreds of submissions and have little patience.

**What a synopsis IS**: A synopsis is NOT a work of literature itself. Its sole purpose is to prove to judges that the story is worth reading in full. Therefore, do NOT critique it as prose fiction. A synopsis conveys the skeleton, structure, and destination of a story. Evaluate "Is the story this synopsis describes compelling?" — NOT "Is this synopsis compelling as a piece of writing?"

Criteria (evaluate the **story itself** as conveyed by the synopsis):
1. **Core idea** — What is the central concept? Does it have enough strength and novelty to sustain a full-length work?
2. **Causal chain** — Does the plot progress with necessity? Are the protagonist's choices and the ending connected by cause and effect?
3. **Character transformation** — What does the protagonist lose and gain through the story? Is that change convincing?
4. **Impact of destination** — Does the ending subvert expectations while remaining satisfying? Does something linger after reading?
5. **Thematic coherence** — Is there a question that runs through the entire story? Does the ending respond to that question?

**IMPORTANT**: Brevity and compression are inherent properties of a synopsis, not flaws. Do NOT make criticisms that would be valid for prose but are irrelevant for a synopsis — e.g., "too expository," "lacks emotional texture," "tells rather than shows."

Output:

```markdown
# 梗概審査: **[通過 / 当落 / 落選]**

## 判定理由
[3-5 sentences. Why this verdict, concisely.]

## 致命的な弱点
[Only for 落選/当落. 1-3 critical issues blocking passage, with specific quotes.]

## 通過に必要なこと
[Only for 落選/当落. 1-3 changes needed, in priority order.]
```

Then branch:

- **落選** → Stop here
- **当落 / 通過** → Proceed to Step 2

## Step 2: Opening Text Review (first 10,000-20,000 chars)

List files in the `story` directory (exclude subdirectories), sort naturally, and read files sequentially until reaching approximately 15,000-20,000 characters, tracking the total character count as you read; stop when you have enough material.

Criteria:
1. **Hook** — Does the first page grab the reader?
2. **Prose** — Style, rhythm, vocabulary, readability
3. **Scene craft** — Scene construction, pacing, transitions
4. **Character introduction** — Are characters introduced effectively?
5. **World-building** — Is the setting conveyed naturally? Not over-explained?
6. **Compulsion** — After 10,000-20,000 chars, do you want to keep reading?

Output:

```markdown
# 本文審査: **[通過 / 当落 / 落選]**

## 判定理由
[3-5 sentences. Why this verdict, concisely.]

## 致命的な弱点
[Only for 落選/当落. 1-3 issues with specific quotes.]

## 通過に必要なこと
[Only for 落選/当落. 1-3 changes in priority order.]
```

Verdict scale:

- **通過**: Passes first round. No major weaknesses, leaves an impression on judges.
- **当落**: Borderline. Has bright spots but also visible weaknesses. Depends on competition.
- **落選**: Cannot pass in current state. Needs fundamental improvement.

Judge without mercy. Praise what deserves praise, but clearly identify weaknesses. Avoid vague language like "almost" or "a bit more" — state specifically what is wrong and how. Always quote from the original text.
