# Performance rules

## Budget

Take the platform and frame rate from the user, and the draw call, triangle and memory limits from what that platform's GPU and memory allow with room left for the effects and UI the greybox lacks.

## Sampler

The sampler is game code with an entry point the headless command or a menu can start. It loads the map, moves the camera through each section of the layout along the player's way through it at eye height, with the section's enemies and effects active where the game has them, holds there a few seconds, and logs per section, tagged `[Perf]`:

`[Perf] <slug> <section> <measure>=<value>...`

with `<section>` the id prefix of the section's pieces and each measure in the budget taken over the frames held there. Measure in a development build on the platform where the user can run one, and in the editor's player otherwise, saying so with the report.

## Fixing

Capture the engine's profiler in the section furthest over budget, fix what costs most there, rebuild, and sample again.
