---
name: proofread
description: 通読しながら誤字脱字・時制の一貫性をチェックする。Use when the user asks to proofread a story file or directory for typos, tense consistency, or notation variance (e.g. "校正して", "proofread this file").
---

The user provides a file path or directory path. If a file path is given, target the entire directory containing that file.

Glob all `.txt` files in the target directory, sort naturally by filename, and launch parallel Agent tools for **ALL** files (one agent per file). Pass the file path and the check items below to each agent. Do NOT check only the specified file.

チェック項目：

- 誤字脱字 — 漢字の変換ミス（同音異義語の取り違え）、送り仮名の誤り、助詞の脱落・重複、文字の脱落・余分な文字、カタカナ語のスペルミス
- 時制の一貫性 — 地の文の基本時制の統一、同一段落内での不自然な時制の揺れ、回想・説明と現在シーンの時制の使い分け
- 表記揺れ — 同一語の漢字/ひらがな表記の混在、固有名詞の表記ブレ

After all agents complete, display the combined results: 問題があった箇所のみ、行番号と引用つきで簡潔に指摘する。問題なしなら「問題なし」。問題が見つかった場合、修正するか確認する。

- 意図的な表現（キャラクターの口調、方言、意図的な時制変化など）は報告しない
- 会話文（「」内）の時制は自由。地の文のみチェック対象
- 判断に迷う箇所は「要確認」として報告
