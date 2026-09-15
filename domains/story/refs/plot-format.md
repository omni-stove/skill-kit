## Plot File Format

```
(Plot body: abstract description of what happens. Dialogue is described as intent/content)

## プロットの意図
(What story this plot is meant to convey. Leave blank by default)

## 禁止事項
(Things this plot must not do. Leave blank by default)

## ハイライト

### 地の文
(Memorable narrative lines, one per line. No quotation marks)

### 会話劇
(Memorable dialogue with 「」. Indicate speaker if not obvious)

## 参照
- @characters/...
- @world/...
- @items/...
```

### プロットの意図
- One or two sentences stating what kind of story this scene/plot is meant to deliver — the author's intent, theme, or emotional target
- Heading is always present; body is blank by default and filled in only when the author has a clear intent to record
- State what the scene conveys, not how the prose achieves it: × 読者だけが気づく仕込みにする / 予告と実演として働く
- Put writing instructions (「〜のように書く」「〜を匂わせない」) in 禁止事項

### 禁止事項
- Bullet list of things this plot must avoid (tonal mistakes, plot moves to rule out, info that must not be revealed yet, etc.)
- Heading is always present; body is blank by default

### Plot Body
- Each paragraph describes what happens: actions, decisions, discoveries, situational changes
- No meta-text: × 沈黙が流れる / ここで読者は○○を知る / 緊張感が高まる / 伏線として機能する / この姿が最後の画になる
- 2-4 sentences per paragraph, ~80-120 chars per line
- Abstract dialogue: ×「行くぞ」→ ○ 出発を促す

### ハイライト
- Lock in specific phrasing worth preserving — distinct from the body which only abstracts
- Heading is always present; subsections (`### 地の文` / `### 会話劇`) are listed only when they have content

### 参照
- Use `@filepath` imports — list the setting files relevant to this scene as bullet items
- One `@path` per line, no other text on the line
- Group order: characters → places → items → world (omit any group with no entries)
- **Inclusion criteria (strict)**:
  - **Characters**: Include only when the character's settings substantially affect this plot's development, decisions, or outcome. Never include just because the character appears or is named
  - **World**: Include only when supplementary information beyond what is written in the current plot body is needed
  - **Places / Items**: Same principle — include only when additional information is essential for understanding the plot or writing the scene
