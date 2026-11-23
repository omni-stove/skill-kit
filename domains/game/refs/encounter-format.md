# Encounter file format

`docs/design/encounters/<slug>.json` holds the enemies of the campaign map whose layout file is `docs/design/maps/<slug>.json`, in its units and axes.

```json
{
  "enemies": { "<type>": { "attack": "melee | ranged", "role": "what it does in a fight", "range": "engagement range in meters", "health": "seconds of the player's attacks it takes" } },
  "surround": { "enemies": "most melee enemies the player can fight at once", "radius": "meters within which melee enemies fight the player together" },
  "encounters": [{
    "id": "",
    "intensity": "1 to 5",
    "entry": "[x, y, z] where the player comes in",
    "exit": "[x, y, z] where the player leaves",
    "trigger": { "pos": "center of the bottom face", "size": "[w, h, d]" },
    "waves": [{
      "start": "trigger | clear | seconds after the previous wave started",
      "enemies": [{ "type": "", "pos": "[x, y, z] where it appears", "hold": "[x, y, z] where it fights from, or where a melee enemy meets the player" }]
    }]
  }]
}
```

List the encounters in route order. Put every `pos` and `hold` on the top of a floor, ramp or stairs piece.
