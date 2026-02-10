# smash-hp

株式会社SMASHのコーポレートサイトです。  
**公開先**: [smash-inc.co.jp](https://smash-inc.co.jp)（予定）  
**News**: WordPress で作成・管理し、REST API で本サイトに表示します。

---

## 公開（smash-inc.co.jp）

1. **ドメイン**  
   smash-inc.co.jp の DNS を、サイトを置くサーバー（レンタルサーバー・Netlify・Vercel など）の A レコードまたは CNAME で向ける。

2. **ファイルのアップロード**  
   - このリポジトリの `index.html` / `news-detail.html` / `style.css` / `assets/` をそのままアップロードする。  
   - または Git 連携でデプロイ（Netlify/Vercel 等ではリポジトリを接続し、公開ディレクトリをルートに指定）。

3. **トップページ**  
   ドメインのルートで `index.html` が表示されるようにする（多くのサーバーは `index.html` を自動で表示）。

---

## News を WordPress で運用する

- **想定**: WordPress を **news.smash-inc.co.jp** に設置し、そこに投稿した記事を本サイトの News セクション・詳細ページで表示しています。
- **API**: `https://news.smash-inc.co.jp/wp-json/wp/v2/posts` を参照しています。

### WordPress 側の準備

1. **WordPress の設置**  
   - サブドメイン `news.smash-inc.co.jp` で WordPress をインストール（レンタルサーバーのサブドメイン設定や別サーバーで可）。

2. **REST API**  
   - 標準のまま利用（投稿の取得は認証不要）。  
   - 固定ページではなく「投稿」を使う。

3. **アイキャッチ画像**  
   - 各投稿にアイキャッチを設定すると、一覧・詳細で表示されます。

4. **別URLにしたい場合**  
   - WordPress を別ドメインやパス（例: `smash-inc.co.jp/wp/`）に置く場合は、以下を書き換えてください。  
   - `index.html`: `.news-track` の `data-api-url` の値。  
   - `news-detail.html`: 先頭付近の `apiBase` の値。

### クロスオリジン（CORS）

- 本サイトを **smash-inc.co.jp**、WordPress を **news.smash-inc.co.jp** で運用する場合、ブラウザから別オリジンへ API アクセスします。
- WordPress の REST API は多くの環境で GET が許可されています。  
  取得できない場合は、サーバーまたは WordPress で `Access-Control-Allow-Origin` に `https://smash-inc.co.jp` を追加する必要がある場合があります。
