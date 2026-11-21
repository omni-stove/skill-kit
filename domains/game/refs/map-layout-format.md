# Map layout file format

Units are meters, y is up, and every piece snaps to the grid.

The layout file is the map's only source; change the map there and rebuild.

```json
{
  "mode": "campaign | competitive",
  "theme": "kebab-case name of the module set the map is dressed in",
  "grid": "cell size every piece snaps to",
  "metrics": { "<name>": "each player dimension, cover height, passage width, step, climb and ceiling height the layout keeps to" },
  "spawns": [{ "team": "", "pos": "[x, y, z]", "yaw": "degrees" }],
  "pieces": [{ "id": "", "kind": "floor | wall | cover | ramp | stairs", "pos": "center of the bottom face", "size": "[w, h, d]", "yaw": "degrees" }]
}
```

Yaw turns clockwise seen from above, and yaw 0 faces +z. A ramp or stairs rises along its local +z. Put height, climb, step or jump in the name of each metric measured upward.
