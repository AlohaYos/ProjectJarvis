# project_jarvis
Custom Gesture UI for Apple Vision Pro
## Progress
### 中間報告
[発表資料](https://github.com/AlohaYos/ProjectJarvis/blob/main/BootCamp001中間.pdf)  
[オープンソース：Hand tracking gesture sample code](https://github.com/AlohaYos/ProjectJarvis/tree/main/HandTrackingDemo)  
### 最終報告
[発表資料](https://github.com/AlohaYos/ProjectJarvis/blob/main/BootCamp001最終.pdf)  
[オープンソース：空間ジェスチャーサンプル VisionGesture](https://github.com/AlohaYos/VisionGesture)

---

## メンバー
[橋本 龍（Moaiman-maker）](https://github.com/Moaiman-maker)  
[橋本 佳幸（AlohaYos）](https://github.com/AlohaYos)

## 概要
ジャンル: AR  
空間ジェスチャーを使って情報へアクセスするUIを試作してオープンソース化する。

## 利用イメージと機能
空間に情報を浮遊させて、それをジェスチャーで整理していくような使い方です。映画「Iron Man」や「Ready Player One」で主人公が行っていたような直感的な操作感を目指しています。また１人称視点ゲーム（FPS）に利用できるような手軽な汎用ジェスチャーも考えていきたいです。

## ターゲット層
- エンドユーザー
    - キーボードやタッチ操作が苦痛で、情報の利用が苦手な人向け。
    - 直感的な操作で、日常空間メタファに合成された情報に触れられるようにしたい。
    - ゲーム関連では、特殊な入力デバイスを用いずに軽快にゲームが行えるようなジェスチャーを用意したい（指先で鉄砲の形を作って撃つとガンシューティングできる等）

- デベロッパー
    - AR空間で自然なジェスチャー操作でアプリや情報を操作させたい開発者向け。
    - ライブラリ形式で提供することで手軽にジェスチャーをインプリメントできるようにしたい。
    - 開発者が新たに考えたジェスチャーをオープンソースとして提供してもらい、ライブラリに取り込む仕組みと環境を提供したい。

## 実装
- 開発環境：visionOS / Xcode
- 開発言語：SwiftUI / Swift
- 3Dモデリング：Reality Composer Pro / Blender / Reality converter etc.

## 展望
空間ジェスチャーはNLUI（自然言語UI）と併用されて、これから広く利用されていくインターフェイスだと考えています。エンジニアがそれぞれジェスチャーを考え個別に実装していくだけではなく、いろんな人が考えたジェスチャーをオープンソースとして持ち寄ってもらい、手軽に利用できるようなジェスチャーUIライブラリを成長させていきたいです。

## 課題
- Vision Proの販売が2024年に予定されているので、実際に動くモノがどこまで試作できるかは未知数ですが、現在提供されているシミュレータで可能な範囲から進めていきます。[Appleのサポート](https://developer.apple.com/visionos/work-with-apple/)も利用していく予定です。
- 共通化できるAPIインターフェイスの策定などが課題になると思います。

## ソースコード
※visionOSのNDAが解けるまではAppleデベロッパー登録している人に限定しての公開です。

## デモサイト
準備中
