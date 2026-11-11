# write

```mermaid
flowchart TD
  author{リポジトリ直下に<br/>author-rules.mdがある?}
  author -- "ある" --> override[既定のルールより<br/>そちらを優先]
  author -- "ない" --> input
  override --> input{入力ファイルは?}
  input -- "プロット" --> exists{本文ファイルがある?}
  exists -- "ある" --> ask[/続きから書くか<br/>最初からやり直すかを聞く/]
  exists -- "ない" --> write
  ask --> write[1 Sceneを書く]
  write --> check[Sceneをチェックして直す]
  check --> reply[/"Scene完了。<br/>y: 次のScene<br/>または修正内容を指示"/]
  reply -- "y、Sceneが残っている" --> write
  reply -- "y、Sceneが残っていない" --> final[ファイル全体をチェック]
  final --> done[/"完了 + ユーザーの<br/>判断に任せる指摘"/]
  reply -- "修正" --> check
  input -- "本文:<br/>ユーザーの指示<br/>どおりに修正" --> rcheck[ファイルをチェックして直す]
  rcheck --> rreply[/"修正完了。<br/>y: 終了<br/>または修正内容を指示"/]
  rreply -- "y" --> final
  rreply -- "修正" --> rcheck
```
