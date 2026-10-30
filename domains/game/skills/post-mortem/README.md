# post-mortem

Writes or edits a post-mortem for a game milestone: what was planned, what happened, what went right and wrong, and the lessons and actions that follow.

Parallelograms are what the user sees and answers.

```mermaid
flowchart TD
  gather[gather the period's commits<br/>and earlier post-mortems]
  gather --> exists{post-mortem for this<br/>milestone exists?}
  exists -- "yes" --> edit[edit it as the user says]
  exists -- "no" --> draft[draft from the commits,<br/>earlier post-mortems and GDD]
  draft --> repeat[/flags lessons an earlier<br/>post-mortem already drew/]
  repeat --> check
  edit --> check[check against the GDD<br/>and existing docs]
  check --> confirm[/presents the draft<br/>for confirmation/]
  confirm -- "revise" --> revise[revise as the user says]
  revise --> check
  confirm -- "OK" --> save[write the post-mortem]
```
