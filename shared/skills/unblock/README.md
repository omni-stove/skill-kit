# unblock

```mermaid
flowchart TD
  scan[check the unlabeled sub-issues<br/>of each open parent issue,<br/>or of the parents named]
  scan --> state{the issues<br/>blocking it?}
  state -- "all completed" --> label[add its label:<br/>the worker starts it]
  state -- "some still open" --> waiting[leave it waiting]
  state -- "one closed<br/>as not planned" --> ask[/asks: start it<br/>as it stands?/]
  state -- "none set" --> judge{the issues it needs,<br/>judged from it and<br/>its parent, all done?}
  judge -- "yes" --> label
  judge -- "no" --> waiting
  ask -- "yes" --> label
  ask -- "no" --> keep[leave it as it is]
  label --> report[/"the labeled issues +<br/>the waiting ones with what<br/>they still wait on +<br/>the ones left as they are"/]
  waiting --> report
  keep --> report
```
