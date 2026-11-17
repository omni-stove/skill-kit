# fix-pr

```mermaid
flowchart TD
  fetch[check out the PR with<br/>the latest commits and<br/>the base branch merged in]
  fetch --> pulled{pulled commits stray<br/>from the PR's intent?}
  pulled -- "yes" --> ask[/shows them and asks<br/>before fixing/]
  pulled -- "no" --> fix
  ask --> fix[fix the threads, failing<br/>checks and conflicts]
  fix --> only{a conflict was<br/>the only problem?}
  only -- "yes" --> merge[/commits only the resolved<br/>paths and pushes,<br/>leaving lint, tests and<br/>the review to CI/]
  only -- "no" --> push[run lint and tests,<br/>commit and push]
  push --> reply[/replies to each thread<br/>and resolves it/]
```
