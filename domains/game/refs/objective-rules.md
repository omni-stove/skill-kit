# Objective rules

## Objectives

- Put each defended objective where its team reaches it `lead` sooner than every other team, and each contested objective where every team reaches it within `even` of the others.
- Give each objective at least two ways in, cover within reach of each, and no single spot a defender watches every way in from.
- Space a team's defended objectives so that the team can rotate between them in about `take`: farther, and attackers take one before help comes; nearer, and one spot defends both.
- Size each objective so that the team on it can spread out instead of stacking on one spot.

## Greybox

The greybox builder places a box per objective and logs, tagged `[Objective]`, one line per objective:

`[Objective] <id> <team>=<seconds>... rotate=<seconds, or ->`

with one `<team>=` per team, the shortest path time on the navigation mesh at the layout's run speed metric from that team's start spawns or `-` where it cannot reach the objective, and `rotate` the shortest path time to the defending team's nearest other objective.

## Match

The game logs, tagged `[Take]`, each time a team takes an objective:

`[Take] <id> team=<team> at=<seconds into the round>`

## Play check

Play rounds with the game's bots or the user's players, filling each team and swapping sides, until the teams have fought over each objective several times.
