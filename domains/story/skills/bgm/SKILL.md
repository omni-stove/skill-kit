---
name: bgm
description: Build a Suno prompt for a BGM track from a story project's settings or a described scene/mood. Use when the user wants a BGM生成プロンプト for a scene, an opening/ending, a character theme, or a described mood, giving what the track is for and optionally a project id.
---

The user supplies what the track is for (a scene, an opening/ending, a character theme, a work-session loop, etc.) and, when the subject belongs to a project, the project id. Without a project id, build the prompt from the user's description alone and skip the setting-file steps.

Resolve every project path by sourcing the layout — run `sh -c '. .agents/refs/layout.sh; <fn> <project-id> [name]'` and use the path it prints. Never hand-build a path. Functions used here: `readme`, `world`, `characters` (the dir), `story`, `story_plot`.

Read only the setting files the subject needs: the story or plot file for a specific scene, `readme` and files under `world` for era and technology level, the character file for a character theme. Extract the emotional arc, the pacing, and the moment the track should underscore.

Ask with a single `AskUserQuestion` call (one round maximum), only for what the request doesn't already imply:

- Usage: シーン伴奏 / オープニング / エンディング / キャラクターテーマ / 作業用ループ.
- Genre direction: orchestral / electronic / acoustic / rock / hybrid.
- Energy: 静か / 抑制 / 高揚 / 激烈.

Build the style prompt in English as comma-separated tags covering genre, mood, tempo, instrumentation, texture, and dynamic arc, under these rules:

- Never include character names or in-world proper nouns — translate every setting into musical terms.
- Never name real artists, composers, or existing works — describe the intended sound in genre, instrumentation, and production terms.
- Match instrumentation to the world's era and technology level unless the user asks for a deliberate anachronism.
- Drop tags that conflict with each other; keep the whole prompt within 200 characters.

Output to the conversation, noting that Suno's Instrumental toggle goes ON:

```markdown
## BGMプロンプト: [シーン/用途]

### Style of Music
[English comma-separated style prompt, ready to paste]

### Exclude Styles
[styles the track must not contain]

### バリエーション
1. [Style of Music — different genre or energy angle]
2. [Style of Music — another angle]

### 意図
[Japanese — why these choices fit the scene]
```

Write no file unless the user names a path to save to.
