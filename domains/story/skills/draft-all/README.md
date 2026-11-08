# draft-all

Writes every plot in `story/plot/` out as text in `draft/` at once. Where a plot leaves something open, the draft fills it in without asking.

Parallelograms are what the user sees and answers.

```mermaid
flowchart TD
  input[every plot file] --> exists{earlier drafts<br/>in draft/?}
  exists -- "yes" --> ask[/asks: overwrite them?/]
  exists -- "no" --> write
  ask -- "yes: every plot,<br/>no: only plots with no draft" --> write[write each plot in parallel,<br/>reading all the plots]
  write --> format[fix the format]
  format --> done[/"files written +<br/>any plot left undrafted"/]
```
