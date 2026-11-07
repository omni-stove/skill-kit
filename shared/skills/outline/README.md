# outline

Before any plot file is made, puts the whole story's events in two orders as Mermaid flowcharts: the order they happen in the story world, and the order the story tells them in. With no told order yet, just the first. Or revises the existing one.

It writes story/outline.md right away from what the files give, then asks for what is missing and adds each answer to the file.

Parallelograms are what the user sees and answers.

```mermaid
flowchart TD
  read[read the settings, timeline,<br/>synopsis and existing plots]
  read --> exists{outline exists?}
  exists -- "yes" --> revise[revise story/outline.md]
  exists -- "no" --> draft[write story/outline.md:<br/>time order and,<br/>if known, the told order]
  revise --> ask
  draft --> ask[/"asks: missing events,<br/>the order they are told in,<br/>guessed places, events<br/>no section shows"/]
  ask -- "answer or feedback" --> fix[add it to story/outline.md]
  fix --> ask
  ask -- "OK" --> done[done]
```
