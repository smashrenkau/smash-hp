# Xserverへアップロードするファイル一覧（WordPress統合版）

**構成**: `smash-inc.co.jp` に WordPress と静的サイトを統合

---

## 📦 アップロード対象ファイル

### メインサイト（smash-inc.co.jp/public_html/）に**追加**アップロード

**⚠️ 重要**: WordPress のファイル（`wp-admin/`、`index.php` など）は**削除せず**、以下のファイルを**追加**してください。

```
smash-hp/
├── index.html                    ← トップページ（追加）
├── news-detail.html              ← News詳細ページ（追加）
├── style.css                     ← スタイルシート（追加）
└── assets/                       ← 画像・アイコン等（追加）
    ├── hero-keyvisual.png
    ├── member-minakawa.png
    ├── member-okugawa.png
    ├── smash-logo.png
    ├── vision-side-left.png
    ├── vision-side-right.png
    └── (その他 assets フォルダ内のすべて)
```

### アップロード後のディレクトリ構成

```
/smash-inc.co.jp/public_html/
├── index.html          ← 追加（静的トップページ）
├── news-detail.html    ← 追加（News詳細）
├── style.css           ← 追加（CSS）
├── assets/             ← 追加（画像フォルダ）
│   ├── hero-keyvisual.png
│   └── ...
├── wp-admin/           ← 既存（WordPress管理画面）
├── wp-content/         ← 既存（テーマ・プラグイン）
├── wp-includes/        ← 既存（WordPressコア）
├── index.php           ← 既存（WordPress本体）
├── .htaccess           ← 既存（後で編集）
└── (その他のWordPressファイル)
```

---

## ⚠️ アップロード不要なファイル（開発用・ドキュメント）

以下は**アップロードしない**でください：

```
❌ .git/                                      ← Git管理用フォルダ
❌ .cursor/                                   ← Cursor IDE設定
❌ README.md                                  ← 開発用ドキュメント
❌ 公開手順.md                                ← 手順書（旧サブドメイン版）
❌ 公開手順_WordPress統合版.md                ← この手順書
❌ クイックスタートガイド.md                  ← ガイド（旧サブドメイン版）
❌ クイックスタートガイド_WordPress統合版.md  ← このガイド
❌ アップロードファイル一覧.md                ← 一覧（旧サブドメイン版）
❌ アップロードファイル一覧_WordPress統合版.md ← このファイル
❌ DESIGN.md                                  ← デザイン資料
❌ VISION_変更手順.md                         ← 開発メモ
❌ .htaccess-sample                           ← サンプル（内容をコピーして使用）
❌ .htaccess-wordpress-sample                 ← サンプル（使用しない）
```

---

## 📂 FTPでのアップロード手順（FileZilla例）

### 1. 接続情報の設定
- ホスト: `smash-inc.co.jp` または `sv〇〇〇〇.xserver.jp`
- ユーザー名: （Xserverサーバーパネルで確認）
- パスワード: （サーバーパネルのパスワード）
- ポート: 21

### 2. アップロード先
リモート側（右側）で以下のフォルダを開く:
```
/smash-inc.co.jp/public_html/
```

**⚠️ 注意**: この場所には既に WordPress のファイルがあります。削除しないでください！

### 3. ファイルをドラッグ＆ドロップ
ローカル側（左側）で以下を選択して、リモート側にドラッグ:
- `index.html`
- `news-detail.html`
- `style.css`
- `assets/` フォルダ（フォルダごと）

### 4. 転送完了を確認
リモート側に以下が**追加**されていればOK:
```
/smash-inc.co.jp/public_html/
├── index.html          ← 新規追加
├── news-detail.html    ← 新規追加
├── style.css           ← 新規追加
├── assets/             ← 新規追加
│   └── （画像ファイル）
├── wp-admin/           ← 既存（保持）
├── wp-content/         ← 既存（保持）
├── index.php           ← 既存（保持）
└── ...
```

---

## 🌐 Xserverファイルマネージャーでのアップロード手順

### 1. ファイルマネージャーを開く
1. Xserverサーバーパネルにログイン
2. 「ファイルマネージャー」をクリック
3. `/smash-inc.co.jp/public_html/` に移動

### 2. 現在のファイルを確認
WordPress のファイル（`wp-admin/`、`wp-content/` など）があることを確認

**⚠️ 重要**: これらは削除しないでください

### 3. ファイルのアップロード

#### HTMLとCSSファイル
1. 「アップロード」ボタンをクリック
2. `index.html`、`news-detail.html`、`style.css` を選択
3. アップロード実行

#### assetsフォルダ
1. 「フォルダ作成」で `assets` フォルダを作成
2. `assets` フォルダに移動
3. 「アップロード」で assets 内のすべてのファイルを選択してアップロード

---

## ✅ アップロード完了後の作業

### 1. .htaccess の編集（必須）

ファイルマネージャーで `/smash-inc.co.jp/public_html/.htaccess` を開き、`.htaccess-sample` の内容にコピー＆ペーストしてください。

詳細は「公開手順_WordPress統合版.md」を参照。

### 2. 動作確認

- https://smash-inc.co.jp にアクセスして静的サイトが表示されることを確認
- https://smash-inc.co.jp/wp-admin/ で WordPress 管理画面にアクセスできることを確認

---

## 🔄 更新時の手順

サイトの内容を更新する場合:

1. ローカルで `index.html` や `style.css` を編集
2. FTPまたはファイルマネージャーで**該当ファイルのみ**上書きアップロード
3. ブラウザでキャッシュをクリア（Ctrl+F5 または Cmd+Shift+R）して確認

**⚠️ 注意**: WordPress ファイルは上書きしないように注意してください

---

作成日: 2026年2月10日
