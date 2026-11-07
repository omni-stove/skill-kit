# outline

プロットファイルを作る前に、物語全体の出来事を2つの順にMermaidのフローチャートで整理する。作中で起きる順（時系列）と、物語が語る順（構成）。語る順がまだなければ時系列だけ。または既存のものを直す。

ファイルからわかる分ですぐ story/outline.md に書き、足りないものを聞いて、答えるたびにファイルへ足していく。

平行四辺形はユーザーに見えて、答えるもの。

```mermaid
flowchart TD
  read[設定、タイムライン、梗概、<br/>既存のプロットを読む]
  read --> exists{全体の流れが<br/>もうある?}
  exists -- "ある" --> revise[story/outline.md を直す]
  exists -- "ない" --> draft[story/outline.md に<br/>時系列と（わかれば）構成を書く]
  revise --> ask
  draft --> ask[/"足りない出来事、語る順、<br/>推測で置いた位置、<br/>どの章にも出ない出来事を聞く"/]
  ask -- "答え・フィードバック" --> fix[story/outline.md に足す]
  fix --> ask
  ask -- "OK" --> done[完了]
```
