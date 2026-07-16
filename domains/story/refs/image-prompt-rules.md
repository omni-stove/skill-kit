# Image-generation prompt rules

The calling skill defines the subject, which setting files to read, and the framing.

Ask with a single `AskUserQuestion` call, one round maximum, only for what the request doesn't already imply: output format (tag style or prose) and art style.

Build the prompt in English:

- Translate names and in-world proper nouns into visible traits.
- Render only what the settings or the user state; keep unstated details neutral.
- Reference style with genre and medium terms, not artist names or existing characters.
- Order the elements: subject → appearance → clothing/equipment → pose & expression → environment → lighting & atmosphere → composition → style & quality terms. Include only the elements the skill's framing calls for.
- Leave titles, logos, and any rendered text out of the prompt.

Output the prompt in a fenced code block; for tag style, add a negative prompt block. Note in Japanese which details the settings left unspecified.
