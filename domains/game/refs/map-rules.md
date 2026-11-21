# Map rules

Units are meters, y is up, and every piece snaps to the grid.

## Layout file

The layout file is the map's only source; change the map there and rebuild.

```json
{
  "grid": "cell size every piece snaps to",
  "metrics": { "<name>": "each player dimension, cover height, passage width, step, climb and ceiling height the layout keeps to" },
  "spawns": [{ "team": "", "pos": "[x, y, z]", "yaw": "degrees" }],
  "pieces": [{ "id": "", "kind": "floor | wall | cover | ramp | stairs", "pos": "center of the bottom face", "size": "[w, h, d]", "yaw": "degrees" }]
}
```

A ramp or stairs rises along its local +z.

## Metrics

Take the metrics from the game's own player where it has one. For a third-person camera, widen passages and raise ceilings until the camera pulled back over the shoulder clears the walls.

## Layout

Decide the map from above: lanes, chokepoints, sightlines, height changes and each team's spawn. For a competitive map, mirror the layout or rotate it about the center.

## Greybox

The builder is an editor script under the project's source root with a headless entry point. It clears one root object and places a primitive per piece under it, bakes the engine's navigation mesh, and logs, tagged `[Greybox]`, each spawn that cannot reach every other team's spawn and each floor piece no spawn can reach.

## Walk check

Put the game's player controller, or the engine's template one, at a spawn, play, walk each lane from each side, and screenshot the long sightlines. Weigh sightline length against cover spacing, a cover within reach of every exposed stretch, and the camera clipping into walls.

## Art

Model grid-sized modules (wall, pillar, floor, stairs, ramp) with a Blender Python script run through a make task, export them under the source root, and have the builder place each piece kind's module in place of its primitive.
