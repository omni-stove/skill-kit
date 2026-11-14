# code

ソフトウェアリポジトリで作業するためのスキル。言語は問わない。アプリが何をするかの記述、共通CI、IssueとPull Requestでの作業の進め方。
`skill-kit code sync` のあと `init` を実行して使い始める。

## 流れ

```mermaid
flowchart TD
  automation[automation<br/>共通CIと設定] --> work
  jsdoc[feature-jsdoc] --> tour[tour]
  work{作業の大きさは?}
  work -- "1セッションに収まる" --> change[コードを変える]
  work -- "大きすぎる" --> issue[delegate]
  issue --> unblock[unblock<br/>待ちのIssueを着手させる]
  change --> pr[pr]
  pr --> review[レビューとCI]
  review -- "指摘、失敗、コンフリクト" --> fixpr[fix-pr]
  fixpr --> review
  review -- "止まったPRが複数" --> fixprs[fix-prs<br/>止まったPRを並列で直す]
  fixprs --> review
```

## 1. リポジトリの準備

- [init](../../shared/skills/init/README.ja.md)
- [task](../../shared/skills/task/README.ja.md)
- [automation](../../shared/skills/automation/README.ja.md)

## 2. アプリを知る

- [feature-jsdoc](skills/feature-jsdoc/README.ja.md)
- [tour](skills/tour/README.ja.md)

## 3. 作業をマージまで運ぶ

- [cap](../../shared/skills/cap/README.ja.md)
- [pr](../../shared/skills/pr/README.ja.md)
- [fix-pr](../../shared/skills/fix-pr/README.ja.md)
- [fix-prs](../../shared/skills/fix-prs/README.ja.md)
- [delegate](../../shared/skills/delegate/README.ja.md)
- [unblock](../../shared/skills/unblock/README.ja.md)
