# Wonder Curling Simulator
文化祭にて披露したカーリングゲーム用のprocessingコード

ArduinoとJoy-Conを用いて遊ぶカーリングシミュレーションゲーム

## 概要
- Arduinoに接続したレーザセンサによって計測した実際のストーンの速度をゲーム内のストーンの速度に変換
- Joy-Conを一本ずつ使用した二人対戦を実現
- 的の中心に近いほど得点が加算
- 隠しコマンドやスタッフロールも実装

## フォルダ内
- WonderCurling/：ゲーム本体のソースコード
- tests/：開発時に使用したテスト用ソースコード群

## 環境
- processing 3
- 主なライブラリ：GameControlPlus, Minim, Serial
