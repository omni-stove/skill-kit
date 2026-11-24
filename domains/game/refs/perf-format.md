# Performance budget format

`docs/design/perf.json` holds the game's performance budget, shared by every map.

```json
{
  "platform": "the device the budget holds on, as the lowest one the game ships to",
  "max": { "<measure>": "the most a section may reach of each measure the sampler logs, as frame_ms, draws, tris or mem_mb" }
}
```

Take `frame_ms` as the 95th-percentile frame time: 16.6 for 60 fps, 33.3 for 30.
