# format-check

Checks one story file against the Japanese web novel format rules and reports only the lines with issues.

Parallelograms are what the user sees and answers.

```mermaid
flowchart TD
  fix[fix mechanical format<br/>issues in place]
  fix --> check[check the file<br/>against every format rule]
  check --> issues{issues left?}
  issues -- "no" --> clean[/"No issues found."/]
  issues -- "yes" --> report[/"lines with issues:<br/>line number + quote<br/>asks: fix them?"/]
  report -- "yes" --> apply[fix the lines]
```
