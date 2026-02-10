# smash-inc.co.jp 公開手順書（WordPress統合版）

**構成**: メインドメイン `smash-inc.co.jp` に WordPress と静的サイトを統合

---

## ✅ 現在の状況

- [x] ドメイン `smash-inc.co.jp` 取得済み
- [x] Xserver 契約済み
- [x] WordPress インストール済み（`https://smash-inc.co.jp/wp-admin/`）

---

## 🎯 実施する作業

1. 静的ファイルのアップロード
2. WordPress パーマリンク設定
3. .htaccess の調整（静的サイトを優先表示）
4. 動作確認

---

## 📂 ステップ1: 静的ファイルのアップロード

### 1-1. Xserver ファイルマネージャーにアクセス

1. [Xserver サーバーパネル](https://www.xserver.ne.jp/)にログイン
2. 「ファイルマネージャー」をクリック
3. `/smash-inc.co.jp/public_html/` に移動

### 1-2. 現在の状態を確認

WordPress インストール時に以下のファイル・フォルダが作成されているはずです：

```
public_html/
├── wp-admin/          ← WordPress管理画面
├── wp-content/        ← テーマ・プラグイン
├── wp-includes/       ← WordPressコア
├── index.php          ← WordPress本体
├── .htaccess          ← WordPress用設定
└── （その他のWordPressファイル）
```

### 1-3. 静的ファイルをアップロード

**⚠️ 重要**: `index.php` は削除せず、`index.html` を追加します。

以下のファイルを `/smash-inc.co.jp/public_html/` にアップロード：

```
✅ index.html           ← トップページ（追加）
✅ news-detail.html     ← News詳細ページ（追加）
✅ style.css            ← スタイルシート（追加）
✅ assets/              ← 画像フォルダ（追加）
```

**アップロード後のディレクトリ構成:**

```
public_html/
├── index.html          ← 新規追加（静的サイト）
├── news-detail.html    ← 新規追加
├── style.css           ← 新規追加
├── assets/             ← 新規追加（フォルダごと）
├── wp-admin/
├── wp-content/
├── wp-includes/
├── index.php           ← 既存（WordPress）
├── .htaccess           ← 既存（後で編集）
└── （その他のWordPressファイル）
```

---

## ⚙️ ステップ2: WordPress パーマリンク設定

### 2-1. WordPress 管理画面にログイン

👉 https://smash-inc.co.jp/wp-admin/

### 2-2. パーマリンク設定を変更

1. 左メニュー「設定」→「パーマリンク」
2. 「投稿名」を選択
3. 「変更を保存」をクリック

---

## 🔧 ステップ3: .htaccess の調整

WordPress と静的サイトを共存させるため、`.htaccess` を編集します。

### 3-1. 現在の .htaccess を確認

ファイルマネージャーで `/smash-inc.co.jp/public_html/.htaccess` を開くと、以下のような内容になっているはずです：

```apache
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
```

### 3-2. .htaccess を編集（推奨設定）

以下の内容に**置き換え**てください：

```apache
# 静的ファイルを優先
DirectoryIndex index.html index.php

# WordPress の設定
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /

# 静的ファイルは WordPress のルーティングから除外
RewriteRule ^index\.html$ - [L]
RewriteRule ^news-detail\.html$ - [L]
RewriteRule ^style\.css$ - [L]
RewriteRule ^assets/ - [L]

# WordPress のルーティング
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
```

**この設定の意味:**
- `DirectoryIndex index.html index.php` → ルートアクセス時に `index.html` を優先表示
- `RewriteRule ^index\.html$ - [L]` など → 静的ファイルは WordPress のルーティングから除外
- 残りはすべて WordPress が処理

### 3-3. 保存して確認

1. ファイルを保存
2. ブラウザで https://smash-inc.co.jp にアクセス
3. 静的サイト（`index.html`）が表示されることを確認

---

## 🔍 ステップ4: 動作確認

### 4-1. トップページの表示確認

👉 https://smash-inc.co.jp
- 静的サイト（index.html）が表示される
- デザインが崩れていない
- Newsセクションが表示される（この時点では記事がなければ「お知らせはありません」と表示）

### 4-2. WordPress 管理画面の確認

👉 https://smash-inc.co.jp/wp-admin/
- 正常にログインできる
- 「投稿」メニューが使える

### 4-3. REST API の動作確認

ブラウザで以下のURLにアクセス：

👉 https://smash-inc.co.jp/wp-json/wp/v2/posts

JSON データが表示されればOK（まだ投稿がない場合は空の配列 `[]` が表示されます）

### 4-4. テスト投稿

1. WordPress 管理画面で「投稿」→「新規追加」
2. タイトル: `テスト投稿`
3. 本文: 適当に入力
4. アイキャッチ画像を設定（推奨）
5. 「公開」をクリック

### 4-5. News セクションの表示確認

1. https://smash-inc.co.jp にアクセス
2. Newsセクションにスクロール
3. 投稿した記事が表示されることを確認（ブラウザをリロード: Ctrl+F5）

### 4-6. 詳細ページの確認

1. 記事カードをクリック
2. `news-detail.html?slug=テスト投稿` に遷移
3. 記事の詳細が表示されることを確認

---

## ✅ 完了チェックリスト

- [ ] `https://smash-inc.co.jp` でトップページ（静的サイト）が表示される
- [ ] `https://smash-inc.co.jp/wp-admin/` で WordPress 管理画面にアクセスできる
- [ ] `https://smash-inc.co.jp/wp-json/wp/v2/posts` で JSON が取得できる
- [ ] WordPress で記事を投稿できる
- [ ] トップページの News セクションに記事が表示される
- [ ] 記事カードをクリックして詳細ページが表示される
- [ ] アイキャッチ画像が表示される

---

## 🎨 WordPress 推奨設定

### 検索エンジンのインデックス制御

WordPress の投稿ページは直接見せないため、WordPress 側のページを検索エンジンにインデックスさせないことを推奨します。

1. WordPress 管理画面：「設定」→「表示設定」
2. 「検索エンジンがサイトをインデックスしないようにする」に**チェックしない**（静的サイトがインデックスされる必要があるため）

ただし、WordPress の投稿ページ（`https://smash-inc.co.jp/テスト投稿/`）が検索結果に出ないようにしたい場合は、SEOプラグイン（Yoast SEO等）で投稿ページのみ `noindex` に設定します。

### テーマ設定

WordPress のフロント表示は使用しないため、テーマはデフォルトのままでOKです。

---

## 📝 日常運用

### 記事を投稿する

1. https://smash-inc.co.jp/wp-admin/ にログイン
2. 「投稿」→「新規追加」
3. タイトル、本文、アイキャッチ画像を設定
4. 「公開」をクリック
5. 数秒後、https://smash-inc.co.jp の News セクションに自動反映

### サイトのデザインを変更する

1. ローカルで `index.html` や `style.css` を編集
2. FTP またはファイルマネージャーで該当ファイルを上書きアップロード
3. ブラウザでキャッシュクリア（Ctrl+F5）して確認

---

## 🔧 トラブルシューティング

### トップページで WordPress が表示される場合

**原因**: `.htaccess` の設定が反映されていない

**対処法**:
1. `.htaccess` の `DirectoryIndex index.html index.php` が正しく記述されているか確認
2. Apache の `AllowOverride` が有効か確認（Xserver では通常有効）
3. ブラウザのキャッシュをクリア（Ctrl+F5）

### News が表示されない場合

**原因1**: まだ投稿がない
→ WordPress で記事を1件投稿してみる

**原因2**: REST API が動作していない
→ https://smash-inc.co.jp/wp-json/wp/v2/posts にアクセスして確認

**原因3**: JavaScript エラー
→ F12 キーで開発者ツールを開き、Console タブでエラーを確認

### WordPress 管理画面にアクセスできない

**原因**: `.htaccess` の設定ミス

**対処法**:
1. ファイルマネージャーで `.htaccess` を開く
2. `RewriteRule ^index\.php$ - [L]` の行が WordPress セクションの最初にあることを確認
3. WordPress の `wp-admin/` ディレクトリが存在するか確認

---

## 🔐 セキュリティ推奨事項

### WordPress のセキュリティ

- [ ] 強固な管理者パスワードを設定
- [ ] 定期的な WordPress アップデート
- [ ] 不要なプラグイン・テーマを削除
- [ ] 「WP Admin Restrict」などでIP制限を検討
- [ ] ログイン URL を変更（プラグイン「WPS Hide Login」等）

### Xserver 全般

- [ ] サーバーパネルのパスワードを強固に
- [ ] FTP アカウントの管理
- [ ] 定期的なバックアップ（Xserver の自動バックアップ機能を確認）

---

## 📞 サポート

### Xserver
- サポート: https://www.xserver.ne.jp/support/
- メール: support@xserver.ne.jp

### WordPress
- 公式: https://ja.wordpress.org/support/

---

## 📋 補足：この構成のメリット・デメリット

### ✅ メリット

1. **CORS問題が発生しない**: 同一ドメインなので追加設定不要
2. **シンプルな構成**: サブドメイン不要
3. **SSL証明書が1つでOK**: メインドメインのみ
4. **WordPress のみで記事管理**: 管理画面が1つ

### ⚠️ デメリット（軽微）

1. **ディレクトリが混在**: WordPress と静的ファイルが同じ場所
2. **.htaccess の管理**: WordPress アップデート時に注意
3. **WordPress ページとの競合**: パーマリンク設定に注意

---

作成日: 2026年2月10日
