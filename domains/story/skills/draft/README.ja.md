# draft

```mermaid
flowchart TD
  input[プロットファイル] --> exists{本文ファイルがある?}
  exists -- "ある" --> ask[/下書きで上書きするか<br/>を聞く/]
  exists -- "ない" --> write
  ask -- "する" --> write[全Sceneを書き、<br/>プロットの不足を<br/>書き留める]
  write --> gap{埋め草にしかならない箇所、<br/>または本文全体の<br/>分量の不足がある?}
  gap -- "ある" --> need[/その箇所ごとに<br/>足りない情報を聞く/]
  need --> fill[答えをもとに<br/>その箇所を書く]
  fill --> format
  gap -- "ない" --> format[書式を直す]
  format --> done[/"report/NNN.md: 分量の不足 +<br/>Sceneごとに、プロットに足りないもの、<br/>下書きでの補い方、<br/>プロットの直し方"/]
```
