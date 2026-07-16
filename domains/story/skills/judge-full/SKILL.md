---
name: judge-full
description: Full manuscript review as a contest final judge. Evaluate whether this work deserves the grand prize. Use when the user asks for a full-manuscript final-round judgment of a project's complete work.
---

The user states the project id, the synopsis file path, and the manuscript file path. Optionally they specify the number of judges (default: 3). Apply contest rules and notes provided in this conversation. If the contest rules are not in the conversation, read the relevant contest-rules file under `.agents/refs/contest-rules/` (e.g. `k.md` = このミステリーがすごい!, `y.md` = 横溝正史, `h.md` = ハヤカワSF) for the contest's $CONTEST_RULES.

**Never read the synopsis or manuscript yourself.** Pass only the file paths to each agent.

Spawn the judge-count number of agents in parallel using the Agent tool with `subagent_type: "contest-judge"`. The `contest-judge` agent definition pins the model to Opus and contains the shared judging instructions, so you only need to provide the case-specific inputs in each agent's prompt:

- The synopsis file path
- The manuscript file path
- The contest rules provided in this conversation (embed verbatim)
- Any notes provided in this conversation (embed verbatim)

Collect all judge results and output:

```markdown
# 最終審査結果

## 審査員投票
[Each judge's verdict, one line each]

## 総合判定: **[大賞 / 大賞ではない]** (N/M)

## 一致した指摘
[Issues raised by multiple judges]

## 分かれた評価
[Points where judges disagreed]
```

Write that output to `out/<project-id>-judge-full-<unix-time>.md` (use `date +%s`).
