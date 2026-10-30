# clarify

Rewrites hard-to-follow passages in a file so readers without specialist knowledge can follow them.

Parallelograms are what the user sees and answers.

```mermaid
flowchart TD
  read[find the hard-to-follow<br/>passages in the file]
  read --> propose[/"proposals: line, original,<br/>rewrite, reason"/]
  propose -- "approved" --> rewrite[rewrite the file]
```
