# Objective file format

The objectives are the `objectives` of the layout file `docs/design/maps/<slug>.json`, each with a unique `id`. `docs/design/objectives/<slug>.json` holds what the mode plays for and the times they are measured against.

```json
{
  "game": "what a team does to win, as plant at a site, carry the other team's flag home or hold points",
  "take": "seconds a team needs at an objective to plant, capture or pick it up",
  "lead": "seconds a defended objective's team reaches it at least before every other team",
  "even": "seconds the teams' times to a contested objective differ at most"
}
```
