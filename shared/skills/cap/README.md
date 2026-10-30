# cap

Commits all current changes and pushes them to the current branch.

Parallelograms are what the user sees and answers.

```mermaid
flowchart TD
  changes{any changes?}
  changes -- "no" --> stop[stop]
  changes -- "yes" --> commit[commit everything with a<br/>message written from the diff]
  commit --> push[push to the current branch]
  push --> result[/the result/]
```
