# write-gemini

```mermaid
flowchart TD
  key{GEMINI_API_KEYが<br/>設定されている?}
  key -- "いない" --> ask[/"exportするよう頼まれる"/]
  key -- "いる" --> send[プロットファイルだけを<br/>WRITE_GEMINI_MODELに渡す<br/>既定はgemini-4-neon]
  send --> out[/"&lt;writeの出力先&gt;.gemini.txt<br/>モデルが書いたまま"/]
```
