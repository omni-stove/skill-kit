# outline

Before any plot file is made, puts the whole story's events in two orders as Markdown: the order they happen in the story world, and the order the story tells them in. Or revises the existing one.

Parallelograms are what the user sees and answers.

```mermaid
flowchart TD
  read[read the settings, timeline,<br/>synopsis and existing plots]
  read --> list[/events found/]
  list --> ask[/"asks: missing events,<br/>the order they are told in"/]
  ask --> exists{outline exists?}
  exists -- "yes" --> revise[revise it]
  exists -- "no" --> draft[arrange the events<br/>in time order and<br/>in the told order]
  revise --> show
  draft --> show[/"both orders + events<br/>no section shows"/]
  show -- "feedback" --> fix[revise on feedback]
  fix --> show
  show -- "OK" --> write[write story/outline.md]
```
