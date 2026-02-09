# Vision セクション変更手順

## 1. 画像について
添付の2枚の画像は次の名前で `assets` フォルダにコピー済みです。
- **左側用**: `assets/vision-side-left.png`
- **右側用**: `assets/vision-side-right.png`

## 2. HTML の変更（index.html）

**現在の Vision セクション**（`vision-layout` の中身で、左右に多数画像が並んでいる部分）を、次のブロックに**丸ごと置き換えて**ください。

```html
        <div class="vision-layout">
          <div class="vision-side vision-side-left fade-in-up">
            <img src="assets/vision-side-left.png" alt="" width="160" height="200" loading="lazy" class="vision-side-img">
          </div>
          <div class="vision-center fade-in-up">
            <p class="vision-lead">誰もが、生活の基盤を築き、<br>安心して新生活を—あるいは再スタートを切れる社会へ。</p>
            <p class="vision-text">
              クレジットカードを持てること。生活必需品に困らないこと。スマートフォンを手にできること。それらは、決して誰にとっても当たり前の環境ではありません。過去の金融トラブルによって、クレジットカードも、ローンも、キャッシングも使えない。目の前の生活費にすら困っている人が、日本には数多く存在しています。家電が壊れても、買い替えられない。子どもの制服を用意できない。必要なスマートフォンがあっても、分割すらできない。「欲しくない」のではなく、「手段がない」だけ。私たちは、そうした人たちがもう一度生活を立て直し、前を向いて歩き出すための現実的な選択肢をつくります。株式会社SMASHは、困難な状況にある人の生活を、マーケティングと仕組みの力で支える会社です。
            </p>
          </div>
          <div class="vision-side vision-side-right fade-in-up">
            <img src="assets/vision-side-right.png" alt="" width="160" height="200" loading="lazy" class="vision-side-img">
          </div>
        </div>
```

- 多数の家電画像（vision-01.png～vision-11.png）は削除し、**中央の文章の両脇に上記2枚だけ**を配置しています。
- ラベル「Vision」と見出し「私たちの想い」はそのままで、その下が「左画像｜中央テキスト｜右画像」の構成になります。

## 3. CSS の変更（style.css）

**削除または上書きするもの**
- `.vision-aside-images` のグリッド（2列でたくさん並べているスタイル）
- `.vision-aside-left` / `.vision-aside-right` の `justify-items` など、多数画像用の指定

**追加・変更するもの**

`.vision-layout` を「中央テキストの高さに合わせて左右画像の高さを揃える」レイアウトにします。

```css
/* ----- Vision（中央テキスト＋両脇に画像1枚ずつ・高さは文字に合わせる） ----- */
.vision-layout {
  display: flex;
  align-items: stretch;
  gap: 2rem 2.5rem;
  margin-top: 0.5rem;
  max-width: 1000px;
  margin-left: auto;
  margin-right: auto;
}
.vision-side {
  flex: 0 0 auto;
  width: 140px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.vision-side-img {
  width: 100%;
  height: 100%;
  object-fit: contain;
  object-position: center;
  display: block;
}
.vision-side-left .vision-side-img { object-position: left center; }
.vision-side-right .vision-side-img { object-position: right center; }
.vision-center {
  flex: 1 1 auto;
  min-width: 0;
}
.vision-center .vision-lead {
  font-size: 1.125rem;
  line-height: 1.75;
  color: #4a4a4a;
  margin: 0 0 1.75rem;
}
.vision-center .vision-text {
  margin: 0;
  font-size: 1rem;
  line-height: 1.9;
  color: #1a1a1a;
}
@media (max-width: 900px) {
  .vision-layout { flex-direction: column; align-items: center; gap: 1.5rem; }
  .vision-side { width: 120px; height: 160px; }
  .vision-side-img { width: 100%; height: 100%; }
}
@media (max-width: 768px) {
  .vision-side { width: 100px; height: 140px; }
}
```

- `align-items: stretch` で、中央のテキストブロックの高さに合わせて左右のエリアが伸びます。
- 左右の `.vision-side` 内の `img` に `height: 100%` を効かせるため、`.vision-side` に `display: flex` と `align-items: center` を指定し、画像は `height: 100%` で「文字の高さ」に合わせています。
- 小さい画面では縦並びにし、画像サイズを少し小さくしています。

## 4. フェードインについて
`.fade-in-up` はそのまま付けたので、既存のスクロール連動フェードインが効きます。不要ならクラスを外してください。

---

**まとめ**
1. 画像は `vision-side-left.png` と `vision-side-right.png` を assets に使用（コピー済み）。
2. index.html の Vision 内の「多数画像のブロック」を、上記の「左1枚・中央テキスト・右1枚」の HTML に差し替え。
3. style.css の Vision まわりを、上記の「中央テキストの高さに合わせた両脇画像」用の CSS に変更。

これで、Vision の文字の両脇に添付画像が1枚ずつ配置され、高さは文字の高さに一致します。
