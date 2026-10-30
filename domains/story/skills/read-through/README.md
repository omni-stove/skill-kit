# read-through

Reads every .txt file in the given file's directory, one at a time, with an impression of each and an overall summary at the end.

Parallelograms are what the user sees and answers.

```mermaid
flowchart TD
  read[read the next file<br/>in the directory]
  read --> imp[write an impression<br/>of that file]
  imp --> left{file left?}
  left -- "yes" --> read
  left -- "no" --> summary[/"overall summary +<br/>where the impressions<br/>are saved"/]
```
