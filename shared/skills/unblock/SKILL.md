---
name: unblock
description: Under each open parent issue, label the unlabeled sub-issues once every issue blocking them is done, so the issue worker starts them, and list the manual ones now the user's to do by hand. Takes optional parent issue numbers. Use when the user wants the waiting issues checked and the ready ones started (e.g. "unblock", "着手できる Issue にラベル付けて", "待ちの Issue を進めて").
---

Run `.agents/skills/unblock/scripts/scan.sh [<parent number>...]`
