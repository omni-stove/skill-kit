# logs

```mermaid
flowchart TD
  read[read recent messages<br/>and runtime exceptions]
  read --> trace[trace them to the<br/>project's own code]
  trace --> report[/"what was logged, what threw,<br/>and where in the code"/]
```
