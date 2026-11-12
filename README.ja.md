# skill-kit

コーディングエージェント向けのスキル集。リポジトリごとにドメインを1つ選んで入れる。どのドメインにも `shared/skills/` の共通スキルが入る。

- **[game](domains/game/README.ja.md)** — ゲーム開発。エンジンは問わない（Unity、Godot、Unreal、自作）。
- **[story](domains/story/README.ja.md)** — 小説の執筆。言語は問わない。
- **[code](domains/code/README.ja.md)** — ソフトウェアリポジトリでの作業。言語は問わない。

[English](README.md)

## はじめかた

`git`、`curl`、[mise](https://mise.jdx.dev) が要る。

1. `skill-kit` を `~/.local/bin` に入れる。

   ```sh
   curl -fsSL https://raw.githubusercontent.com/omni-stove/skill-kit/main/install.sh | sh
   ```

2. 対象のgitリポジトリで、ドメインを選んでsyncする。

   ```sh
   skill-kit code sync     # または game / story
   ```

3. `init` スキルを実行する。ゲームのリポジトリなら `setup` スキルも実行する。
4. あとは `guide` スキルに、何をしたいか、次に何をすればいいかを聞く。

リポジトリをcloneした人は `make setup` を、最新のキットにするには `make update` を実行する。

## 1つのリポジトリでだけスキルを変える

キットのリンクがある場所（例: `.claude/skills/<name>/`）に
同じ名前の実ファイルを置く。syncはそれに触れない。

## キット自体の開発

clone後に `make setup`、pullと再syncには `make update` を実行する。
