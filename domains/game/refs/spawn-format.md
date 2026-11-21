# Spawn file format

The respawn points are the spawns with `use: respawn` in the layout file `docs/design/maps/<slug>.json`, each with a unique `id`. `docs/design/spawns/<slug>.json` holds how the game picks among them.

```json
{
  "respawn": "each | wave",
  "delay": "seconds from death to respawn, or between waves",
  "protect": "seconds a respawned player cannot be hurt, 0 for none",
  "min_enemy_time": "seconds an enemy needs at least to run to a respawn point from any spawn of its team",
  "spawn_kill": "a death within this many seconds of respawning counts as a spawn kill",
  "weights": { "enemy_time": "relative weight of each score", "teammate_near": "", "recent_death": "" }
}
```
