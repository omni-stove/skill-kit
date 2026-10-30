# post-mortem

ゲームのマイルストーンのポストモーテム（計画、実際、良かった点と悪かった点、そこから得た教訓と次の行動）を書く・編集する。

平行四辺形はユーザーに見えて、答えるもの。

```mermaid
flowchart TD
  gather[期間中のコミットと<br/>過去のポストモーテムを集める]
  gather --> exists{このマイルストーンの<br/>ポストモーテムがある?}
  exists -- "ある" --> edit[指示どおりに編集]
  exists -- "ない" --> draft[コミット、過去の<br/>ポストモーテム、GDDから下書き]
  draft --> repeat[/過去のポストモーテムで<br/>既に出た教訓を指摘/]
  repeat --> check
  edit --> check[GDDと既存の<br/>文書に照らしてチェック]
  check --> confirm[/下書きを見せて<br/>確認を求める/]
  confirm -- "修正" --> revise[指示どおりに直す]
  revise --> check
  confirm -- "OK" --> save[ポストモーテムを書き出す]
```
