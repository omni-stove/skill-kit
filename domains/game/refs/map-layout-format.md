# Map layout file format

Units are meters, y is up, and every piece snaps to the grid.

The layout file is the map's only source; change the map there and rebuild.

```json
{
  "mode": "campaign | competitive",
  "theme": "kebab-case name of the module set the map is dressed in",
  "grid": "cell size every piece snaps to",
  "metrics": { "<name>": "each player dimension and the run speed, cover height, passage width, step, climb and ceiling height the layout keeps to" },
  "beats": [{ "id": "the id its section's pieces start with", "name": "", "notes": ["what happens in the section that the pieces cannot hold"] }],
  "backdrop": ["what is seen beyond the map's bounds"],
  "spawns": [{ "id": "", "team": "", "use": "start | respawn", "pos": "[x, y, z]", "yaw": "degrees", "note": "" }],
  "pieces": [{ "id": "", "kind": "floor | wall | cover | ramp | stairs", "pos": "center of the bottom face", "size": "[w, h, d]", "yaw": "degrees", "note": "" }]
}
```

Start each piece's id with its section's id and a hyphen, as `s3-wall-w`. Keep the beats, backdrop and notes when changing the layout, and rename a beat's id with its pieces. Have every builder parse the layout so that a field it does not place, such as `beats`, `backdrop` or `note`, is skipped rather than an error.

Yaw turns clockwise seen from above, and yaw 0 faces +z. A ramp or stairs rises along its local +z. Put height, climb, step or jump in the name of each metric measured upward. A spawn without `use` is one the match or the route starts at.
