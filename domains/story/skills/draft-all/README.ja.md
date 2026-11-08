# draft-all

`story/plot/` のすべてのプロットを、まとめて `draft/` に本文として書き出す。プロットが決めていないところは、聞かずに補って書く。

平行四辺形はユーザーに見えて、答えるもの。

```mermaid
flowchart TD
  input[すべてのプロットファイル] --> exists{draft/ に<br/>前の下書きがある?}
  exists -- "ある" --> ask[/上書きするかを聞く/]
  exists -- "ない" --> write
  ask -- "する: すべてのプロット<br/>しない: 下書きのないプロットのみ" --> write[すべてのプロットを読んで<br/>各プロットを並行して書く]
  write --> format[書式を直す]
  format --> done[/"書き出したファイル +<br/>書けなかったプロット"/]
```
