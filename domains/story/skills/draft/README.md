# draft

Writes a plot file out as a whole story file in one pass, then hands the plot back with
where it falls short. The plot file is left as it is.

Parallelograms are what the user sees and answers.

```mermaid
flowchart TD
  input[plot file] --> exists{story file exists?}
  exists -- "yes" --> ask[/asks: overwrite<br/>with the draft?/]
  exists -- "no" --> agent
  ask -- "yes" --> agent[subagent reports what<br/>the plot must stay<br/>consistent with,<br/>reading no later file,<br/>outline or synopsis]
  agent --> write[write every Scene,<br/>noting where the<br/>plot falls short]
  write --> gap{a passage would<br/>only fill space?}
  gap -- "yes" --> need[/asks for the information<br/>each such passage lacks/]
  need --> fill[write those passages<br/>from the answers]
  fill --> format
  gap -- "no" --> format[fix the format]
  format --> done[/"drafted + per Scene: what the plot lacks,<br/>how the draft filled it in,<br/>and how the plot could be fixed"/]
```
