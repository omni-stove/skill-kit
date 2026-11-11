# run

```mermaid
flowchart TD
  how{このリポジトリでの<br/>ゲームの動かし方は?}
  how -- "Computer Use" --> play_ed[エディタでPlayを押し、<br/>変えた流れを遊んで<br/>Game viewを撮る]
  how -- "エンジンと接続" --> drive[Play Mode、テスト、<br/>ビルドを操作する]
  how -- "ヘッドレス" --> headless[ヘッドレスで実行]
  how -- "シェルから" --> build[ビルドしてから実行]
  how -- "手作業のみ" --> manual[/手作業の手順を<br/>伝えて待つ/]
  play_ed --> up
  drive --> up[起動したか確認]
  headless --> up
  build --> up
  manual --> up
  up --> play[実際の流れを操作し<br/>ゲームの出力を読む]
  play --> result[/変更が動いているか/]
```
