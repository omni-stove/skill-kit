# write-gemini

```mermaid
flowchart TD
  key{GEMINI_API_KEY<br/>is set?}
  key -- "no" --> ask[/"asked to export it"/]
  key -- "yes" --> send[the plot file alone<br/>goes to WRITE_GEMINI_MODEL<br/>default gemini-4-neon]
  send --> fix[the reply is fixed<br/>by the guards]
  fix --> out[/"&lt;write's output&gt;.gemini.txt<br/>and each finding left open"/]
```
