# smash-hp

株式会社SMASHのコーポレートサイトです。  
**公開先**: [smash-inc.co.jp](https://smash-inc.co.jp)  
**News**: WordPress で作成・管理し、REST API で本サイトに表示します。

---

## 🚀 公開方法

### 構成

WordPress と静的サイトを **同一ドメイン `smash-inc.co.jp`** で統合運用

- **静的サイト**: `index.html`、`news-detail.html`、`style.css`、`assets/`
- **WordPress**: `smash-inc.co.jp/wp-admin/`（記事管理用）
- **News API**: `https://smash-inc.co.jp/wp-json/wp/v2/posts`

### クイックスタート

👉 **`クイックスタートガイド_WordPress統合版.md`** をご覧ください（約15分で公開完了）

詳細な手順は **`公開手順_WordPress統合版.md`** をご参照ください。

---

## 📝 ファイル構成

### 本番環境にアップロードするファイル

```
/smash-inc.co.jp/public_html/
├── index.html          ← トップページ
├── news-detail.html    ← News詳細ページ
├── style.css           ← スタイルシート
├── assets/             ← 画像フォルダ
├── wp-admin/           ← WordPress（既存）
├── wp-content/         ← WordPress（既存）
└── .htaccess           ← 編集必要
```

詳細は **`アップロードファイル一覧_WordPress統合版.md`** をご参照ください。

---

## 🔧 重要な設定

### .htaccess の設定

WordPress と静的サイトを共存させるため、`.htaccess` の編集が必要です。

サンプルファイル: **`.htaccess-sample`**

```apache
# 静的ファイルを優先
DirectoryIndex index.html index.php

# 静的ファイルは WordPress のルーティングから除外
RewriteRule ^index\.html$ - [L]
RewriteRule ^news-detail.html$ - [L]
RewriteRule ^style\.css$ - [L]
RewriteRule ^assets/ - [L]
```

### WordPress パーマリンク設定

WordPress 管理画面：「設定」→「パーマリンク」→「投稿名」を選択

---

## 📰 News の仕組み

1. **WordPress で記事を投稿**（`smash-inc.co.jp/wp-admin/`）
2. **REST API で記事データを取得**（`/wp-json/wp/v2/posts`）
3. **静的サイトで自動表示**（`index.html` の News セクション）
4. **詳細ページで表示**（`news-detail.html`）

### API URL

- **トップページ（News一覧）**: `index.html` 67行目
  ```html
  data-api-url="https://smash-inc.co.jp/wp-json/wp/v2/posts"
  ```

- **詳細ページ**: `news-detail.html` 59行目
  ```javascript
  var apiBase = 'https://smash-inc.co.jp/wp-json/wp/v2/posts';
  ```

---

## ✅ 公開後の運用

### 記事の投稿

1. https://smash-inc.co.jp/wp-admin/ にログイン
2. 「投稿」→「新規追加」
3. タイトル、本文、アイキャッチ画像を設定
4. 「公開」

→ 数秒後、トップページの News セクションに自動反映

### サイトの更新

1. ローカルで HTML/CSS を編集
2. FTP またはファイルマネージャーでアップロード
3. ブラウザでキャッシュクリア（Ctrl+F5）

---

## 📚 ドキュメント

- **クイックスタートガイド_WordPress統合版.md**: 最短15分で公開
- **公開手順_WordPress統合版.md**: 詳細な手順とトラブルシューティング
- **アップロードファイル一覧_WordPress統合版.md**: アップロードファイルの詳細

---

## 🔐 セキュリティ

- WordPress 管理画面のパスワードを強固に
- 定期的な WordPress アップデート
- 不要なプラグイン・テーマの削除
- ログインURL変更プラグインの導入推奨

---

作成日: 2026年2月10日
