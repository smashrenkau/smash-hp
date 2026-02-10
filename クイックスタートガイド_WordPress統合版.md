# 🚀 smash-inc.co.jp 公開クイックスタート（WordPress統合版）

**所要時間**: 約15分

**現在の状況**: WordPress は既に `smash-inc.co.jp/wp-admin/` にインストール済み

---

## ステップ1: 静的ファイルをアップロード（10分）

### Xserver ファイルマネージャーにログイン

👉 https://www.xserver.ne.jp/login_server.php
1. サーバーパネルから「ファイルマネージャー」をクリック
2. `/smash-inc.co.jp/public_html/` に移動

### 以下のファイルをアップロード

WordPress のファイルと同じ場所に、以下を追加アップロード：

```
✅ index.html
✅ news-detail.html
✅ style.css
✅ assets/ フォルダ（中身すべて）
```

**⚠️ 注意**: `index.php` や `wp-admin/` などの WordPress ファイルは**削除しないでください**

---

## ステップ2: .htaccess を編集（3分）

### ファイルマネージャーで `.htaccess` を開く

`/smash-inc.co.jp/public_html/.htaccess` を編集

### 以下の内容に置き換え

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

保存してください。

---

## ステップ3: WordPress パーマリンク設定（1分）

### WordPress 管理画面にログイン

👉 https://smash-inc.co.jp/wp-admin/

### パーマリンク設定

1. 左メニュー「設定」→「パーマリンク」
2. 「投稿名」を選択
3. 「変更を保存」

---

## ステップ4: 動作確認（1分）

### トップページ確認

👉 https://smash-inc.co.jp
→ 静的サイトが表示されればOK！

### REST API 確認

👉 https://smash-inc.co.jp/wp-json/wp/v2/posts
→ JSON が表示されればOK（まだ投稿がなければ `[]` と表示されます）

---

## ステップ5: テスト投稿（1分）

### 記事を投稿

1. WordPress 管理画面：「投稿」→「新規追加」
2. タイトル: `テスト投稿`
3. 本文: 適当に入力
4. アイキャッチ画像を設定（推奨）
5. 「公開」

### News セクションで確認

👉 https://smash-inc.co.jp
→ Newsセクションにスクロール
→ 投稿した記事が表示されていればOK！（Ctrl+F5 でリロード）

---

## 🎉 完了！

おめでとうございます！サイトが公開されました。

---

## 📝 日常運用

### 記事を投稿するには

1. https://smash-inc.co.jp/wp-admin/ にログイン
2. 「投稿」→「新規追加」
3. タイトル・本文・アイキャッチを設定
4. 「公開」

→ 数秒後、自動的に https://smash-inc.co.jp の News に反映！

---

## ⚠️ トラブルシューティング

### トップページで WordPress が表示される

→ `.htaccess` の `DirectoryIndex index.html index.php` が正しく記述されているか確認
→ ブラウザのキャッシュをクリア（Ctrl+F5）

### News が表示されない

→ WordPress で記事を1件投稿してみる
→ https://smash-inc.co.jp/wp-json/wp/v2/posts で JSON が取得できるか確認

---

## 📞 詳細な手順は

`公開手順_WordPress統合版.md` をご参照ください。

---

作成日: 2026年2月10日
