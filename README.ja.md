# skill-kit

コーディングエージェント向けのスキル集。共通の土台を持つ3つのドメインからなる。

- **[game](domains/game/README.ja.md)** — ゲーム開発。エンジンは問わない（Unity、Godot、Unreal、自作）。
- **[story](domains/story/README.ja.md)** — 小説の執筆。言語は問わない。
- **[code](domains/code/README.ja.md)** — ソフトウェアリポジトリでの作業。言語は問わない。

各ドメインのガイドに、スキルを使う順番とファイルの置き場所がある。どのドメインにも共通スキルが入る:
makeのコマンド用の `init` と `task`、git用の `cap` と `pr`、設定用の `character`、`world`、`item`、`outline`。

各スキルの `README.ja.md`（`shared/skills/<name>/`、`domains/<domain>/skills/<name>/`）に、
そのスキルが何を聞き、何を返すかがある。

[English](README.md)

## 必要なもの

`git`、`curl`、[mise](https://mise.jdx.dev)。対象はgitリポジトリ。

## インストール

```sh
curl -fsSL https://raw.githubusercontent.com/omni-stove/skill-kit/main/install.sh | sh
```

`~/.local/bin` に `skill-kit` が入る。

## リポジトリの準備

最初に1回、そのリポジトリで:

```sh
skill-kit code sync     # または game / story
```

次に `init` スキルを実行する。リポジトリのツールとコマンドをmiseとmakeに載せる。
ゲームのリポジトリなら、`setup` スキルも実行してキットをエンジンに合わせる。

そのあとは、リポジトリをcloneした人は `make setup` を、最新のキットにするには `make update` を実行する。
ほかはすべてエージェントがやる。

キットのスキルを1つのリポジトリでだけ変えるには、キットのリンクがある場所（例: `.claude/skills/<name>/`）に
同じ名前の実ファイルを置く。syncはそれに触れない。

## フック

**llm-instruction-rules** は、Claudeが `SKILL.md`、`AGENTS.md`、プロンプトを編集するたびに、
指示文を書くときのルールを見せる。`init` が登録する。

**run-skill-scripts** は、ClaudeとCodexがスキルのスクリプトを開いて読むのを止め、そのまま実行させる。`init` が両方に登録する。
Codexで効くのは、リポジトリをtrustedにし、Codex上で新しいフックを承認してから。

**before-skill** はスキルの前にコマンドを実行し、コマンドが失敗したらスキルを止める。
`.claude/settings.json` の `hooks.PreToolUse` に自分で登録する。この例は `pr` の前に `make check` を実行する:

```json
{
  "matcher": "Skill",
  "hooks": [
    { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR/.claude/hooks/before-skill.sh\" pr make check", "timeout": 600 }
  ]
}
```

## キット自体の開発

clone後に `make setup`、pullと再syncには `make update` を実行する。
