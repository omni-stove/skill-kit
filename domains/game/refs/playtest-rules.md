# Playtest rules

## Log

The game logs, tagged `[Play]`, in the layout's units and axes:

`[Play] <kind> <x>,<y>,<z> [from=<x>,<y>,<z>]`

- `death` where the player dies, `from` where the killer stood
- `hit` where the player takes damage, `from` where it came from
- `stuck` once where the player stays within a few meters for a long while with no enemy in sight

Log the player's feet, from the player's own code, in every build a tester plays.

## Play check

Play the map as a newcomer would, from its start to the route's end or through full matches from each team's start, several times. Where the user can bring in testers who have not seen the map, have each one play and collect each one's log.

## Reading

- Deaths bunched at one spot with `from` out of the player's view mark a hold, spawn or sightline the player cannot see coming.
- Hits from far beyond the enemies' range or through walls mark a sightline the layout did not mean.
- Stuck points mark where the way on does not read or the collision catches the player.
- Weigh each section against its beat: few deaths where a control is taught, the most at the hardest encounter, and for a campaign a rise along the route matching each encounter's intensity.
- Weigh a competitive map's teams against each other: deaths mostly on one team's side mark an advantage of the other's.
