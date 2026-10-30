# judge-full

A panel of final-round judges decides whether a complete manuscript wins the 大賞, discussing where they split.

Parallelograms are what the user sees and answers.

```mermaid
flowchart TD
  judges["judges (3 by default)<br/>each read the synopsis<br/>and the whole manuscript"]
  judges --> first[/"first-round tally:<br/>each judge's verdict,<br/>where they agree and split"/]
  first --> split{still split?}
  split -- "yes" --> discuss[each judge rebuts or<br/>concedes the others'<br/>points, may change verdict]
  discuss --> moved[/"verdicts and<br/>what moved"/]
  moved --> again{"still split and<br/>a verdict changed?"}
  again -- "yes" --> discuss
  again -- "no" --> final
  split -- "no" --> final[/"final vote N/M:<br/>大賞 or 大賞ではない,<br/>what stayed split"/]
```
