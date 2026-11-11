# write

```mermaid
flowchart TD
  input{input file?}
  input -- "plot" --> exists{story file exists?}
  exists -- "yes" --> ask[/asks: continue<br/>or start over?/]
  exists -- "no" --> write
  ask --> write[write 1 Scene]
  write --> check[check and fix the Scene]
  check --> reply[/"Scene complete.<br/>y: next Scene<br/>or say what to revise"/]
  reply -- "y, Scene left" --> write
  reply -- "y, no Scene left" --> final[check the whole file]
  final --> done[/"complete + findings left<br/>for the user to decide"/]
  reply -- "revise" --> check
  input -- "story:<br/>revise as the user says" --> rcheck[check and fix the file]
  rcheck --> rreply[/"revised.<br/>y: finish<br/>or say what to revise"/]
  rreply -- "y" --> final
  rreply -- "revise" --> rcheck
```
