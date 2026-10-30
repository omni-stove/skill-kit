# block-breaks

日本語の小説ファイルのブロック区切りと空行を直す。

平行四辺形はユーザーに見えて、答えるもの。

```mermaid
flowchart TD
  read[ファイルを読む]
  read --> fix[ブロック区切りと<br/>空行を直す]
  fix --> report[/変更内容/]
```
