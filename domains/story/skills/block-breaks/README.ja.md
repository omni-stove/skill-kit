# block-breaks

```mermaid
flowchart TD
  read[ファイルを読む]
  read --> fix[ブロック区切りと<br/>空行を直す]
  fix --> report[/変更内容/]
```
