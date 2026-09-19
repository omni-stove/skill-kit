# Japanese Web Novel Format Rules

- Plain text only; no markdown formatting
- Separate scenes with `◇◇◇` on its own line; blank lines only there, one before and one after
- Indent the first character of each narration paragraph with a full-width space; lines starting with 「 or 『 stay unindented
- Give each line of dialogue a line of its own
- Merge consecutive dialogue from the same speaker, or insert narration between
- ……: forbidden
- ――: speech cut off mid-line, or a pause or lingering beat in dialogue or narration (always paired)
- ！／？: add a full-width space after (may omit if obvious)
- 『』: inner thoughts, book titles, emphasis
- No period at the end of dialogue
- Use kanji numerals, with 〇 for zero and ・ as the decimal point (〇・五)
- Ruby: `|単語《ルビ》`
