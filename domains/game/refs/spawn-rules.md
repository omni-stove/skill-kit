# Spawn rules

## Points

- Place respawn points in groups by area on each team's side, more points per group than the team's size, each facing into the map toward cover.
- Keep each point at least `min_enemy_time` from every other team's spawn and out of its sight.
- Give each team more than one group, spread so one push cannot cover them all.

## Selection

Drop each respawn point a living enemy sees or can reach within `min_enemy_time`. Score the rest by the weights: the living enemies' path time to it, teammates near it, and deaths near it in the last few seconds, and pick at random among the best few. With every point dropped, take the one the enemies need longest to reach. For wave respawns, score each group the same way and place the team at its points. Log each respawn tagged `[Respawn]`:

`[Respawn] <id> died_after=<seconds>`

with the seconds the respawned player lived, written at that player's next death.

## Greybox

The greybox builder logs, tagged `[Spawn]`, one line per respawn point:

`[Spawn] <id> team=<team> enemy_time=<seconds> from=<spawn id> seen_by=<spawn ids joined by commas, or ->`

`enemy_time` is the shortest path time on the navigation mesh at the layout's run speed metric from any spawn of another team, and `from` is that spawn. `seen_by` lists the other teams' spawns with a clear line from eye height to eye height.

## Play check

Play matches with the game's bots or the user's players, filling each team, until every respawn point has been picked several times.
