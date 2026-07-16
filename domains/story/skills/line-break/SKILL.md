---
name: line-break
description: 地の文を文脈の変わり目で改行する。Use when the user asks to insert meaning-unit line breaks into a Japanese fiction file's narrative prose.
---

The user specifies the target file path.

対象ファイルを読み込み、地の文で、同じ行内に文脈の異なる文が連なっている場合、文脈の変わり目で改行する。

- 同じ話題・描写が続く文は1行にまとめたままでよい
- 話題・視点・動作の主体が変わるところで切る
- 改行後の行は元と同じインデント（全角スペース）を維持し、空行は入れない
- 会話文は対象外

変更した行数を簡潔に報告する。
