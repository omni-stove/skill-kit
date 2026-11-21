# Shooter map rules

## Metrics

Take the metrics from the game's own player where it has one. For a third-person camera, widen passages and raise ceilings until the camera pulled back over the shoulder clears the walls.

## Layout

Decide the map from above, then measure each slope, passage width and ceiling height against the metrics and fix what fails.

## Greybox

The builder is an editor script under the project's source root with a headless entry point. It clears one root object and places a primitive per piece under it, bakes the engine's navigation mesh, and logs, tagged `[Greybox]`, each spawn that cannot reach every other team's spawn and each floor piece no spawn can reach. For a campaign layout it logs instead each spawn and each floor piece the first player spawn cannot reach.

## Walk check

Put the game's player controller, or the engine's template one, at a spawn, play, walk every way through the map from each end, and screenshot the long sightlines. Weigh sightline length against cover spacing, a cover within reach of every exposed stretch, and the camera clipping into walls.
