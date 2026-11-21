# game

ゲーム開発のためのスキル。エンジンは問わない（Unity、Godot、Unreal、自作）。ゲームをビルド・実行・修正し、マイルストーンをふりかえる。
`skill-kit game sync` のあと `init`、次に `setup` を実行して使い始める。

## 流れ

```mermaid
flowchart TD
  setup[setup<br/>キットをエンジンに合わせる] --> mcp[setup-mcp<br/>任意]
  setup --> impl[実装]
  mcp --> impl
  impl --> run[run]
  run --> broken{動く?}
  broken -- "コンパイルエラー" --> fix[fix]
  broken -- "実行時におかしい" --> logs[logs]
  fix --> run
  logs --> impl
  broken -- "動く、マイルストーン完了" --> pm[post-mortem]
```

## 1. セットアップ

- [setup](skills/setup/README.ja.md)
- [setup-mcp](skills/setup-mcp/README.ja.md)

## 2. ビルド・実行・修正

- [run](skills/run/README.ja.md)
- [fix](skills/fix/README.ja.md)
- [logs](skills/logs/README.ja.md)

## 3. 作業をマージまで運ぶ

- [cap](../../shared/skills/cap/README.ja.md)
- [pr](../../shared/skills/pr/README.ja.md)
- [fix-pr](../../shared/skills/fix-pr/README.ja.md)
- [fix-prs](../../shared/skills/fix-prs/README.ja.md)
- [delegate](../../shared/skills/delegate/README.ja.md)
- [unblock](../../shared/skills/unblock/README.ja.md)
- [work-issues](../../shared/skills/work-issues/README.ja.md)
- [automation](../../shared/skills/automation/README.ja.md)

## 4. ふりかえり

- [post-mortem](skills/post-mortem/README.ja.md)

## マップ

- [shooter-map](skills/shooter-map/README.ja.md)
- [map-art](skills/map-art/README.ja.md)
- [shooter-encounter](skills/shooter-encounter/README.ja.md)
- [shooter-spawns](skills/shooter-spawns/README.ja.md)

## 設定

物語のあるゲームなら、[character](../../shared/skills/character/README.ja.md)、
[world](../../shared/skills/world/README.ja.md)、[item](../../shared/skills/item/README.ja.md)、
[outline](../../shared/skills/outline/README.ja.md) もここで使える。
その設定から画像生成プロンプトを作る [tachie](../../shared/skills/tachie/README.ja.md) と
[background](../../shared/skills/background/README.ja.md) も使える。

## 資料を読ませる

- [load](../../shared/skills/load/README.ja.md)
