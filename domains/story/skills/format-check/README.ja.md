# format-check

```mermaid
flowchart TD
  fix[機械的に直せる書式を<br/>その場で直す]
  fix --> check[ファイルをすべての<br/>書式ルールでチェック]
  check --> issues{問題が残っている?}
  issues -- "ない" --> clean[/"No issues found."/]
  issues -- "ある" --> report[/"問題のある行:<br/>行番号 + 引用<br/>直すかを聞く"/]
  report -- "直す" --> apply[その行を直す]
```
