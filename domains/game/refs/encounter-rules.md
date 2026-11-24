# Encounter rules

## Enemies

Take the enemy types, their attack, ranges and health from the game's code where it has them, and `surround` from how many attackers the player's own melee code lets the player block or answer at once.

## Encounters

- Spawn each enemy out of the player's sight from wherever the player stands when its wave starts.
- Put each ranged enemy's hold at cover facing the way the player comes in, within its range of the entry.
- Put each melee enemy's hold where it meets the player on the way in, and bring it from a side the player faces.
- Keep the melee enemies of a wave that meet the player together within `surround`, except where the section's beat calls for the player to be surrounded.
- Let the player see the first wave from the entry before it attacks.
- Mix roles in a wave so that holding one spot loses: one enemy that holds, one that pushes or flanks.
- Leave the player cover within reach of the entry and a flank no hold covers.
- Bring a later wave from a new direction, and give the player a sound or a visible opening before it attacks.
- Rate intensity by the number and threat of enemies at once. Raise it along the route with a lighter encounter or a connector after each peak, and make the last encounter the hardest.

## Greybox

The greybox builder also reads the encounter file. Where the game has its own enemies and encounter system, it spawns those through it; otherwise it places a marker per enemy spawn and hold and a box per trigger under its root. It logs, tagged `[Encounter]`, each enemy whose spawn cannot reach its hold on the navigation mesh, each trigger the player's path from the previous encounter's exit to this entry does not cross, and each spawn of a wave its trigger starts that is in line of sight of the trigger's center at eye height.

## Play check

Play each encounter from its entry with the game's enemies, or with stand-ins that walk to their hold and fire along their sightline, or run at the player for a melee enemy. Note where the player is hit from out of view, how long clearing takes, how often the player dies, and whether the way on reads once the last wave falls. Weigh these against the intensity, and fix the encounter file.
