# かんたん家計簿 (kakeibo-app)

PC・スマホ両方のブラウザから使える家計簿アプリ。データは Firebase Firestore に保存され、どの端末で入力しても同じ一覧に反映される（リアルタイム同期）。

- 公開URL: https://basukeman0809-gif.github.io/kakeibo-app/
- ホスティング: GitHub Pages
- データベース: Firebase Firestore（プロジェクト: `kakeibo-app-ac30a`）

## 使い方

1. 上記URLを開く
2. PINコードを入力してロックを解除
3. フォームから収入・支出を入力して「記録する」（PCでもスマホでも同じ画面）

## セキュリティについて（重要）

- ログイン機能（Firebase Authentication）は使っておらず、**PINコードはWebページ側だけの簡易的な鍵**
- Firestoreのセキュリティルールは `entries` コレクションを誰でも読み書きできる設定にしている（`allow read, write: if true;`）
- そのため、URLとFirebaseの設定情報（`projectId`など、コード中に書かれている）を知っていれば、PINを介さず直接データへアクセスすることも理論上可能
- 個人の家計簿用途を想定した簡易的な保護であり、厳密なアクセス制御が必要な場合はFirebase Authenticationの導入が必要

## Claude に話しかけて自動入力する

この作業ディレクトリで Claude Code に「ラーメン1200円」のようにメッセージを送ると、Claude が内容を解析し、Firestore REST API 経由で直接エントリーを追加する。ページを開いていれば（PC・スマホ問わず）リアルタイムに反映される。

### エントリーの形式（Firestoreドキュメント）

```js
{
  date: 'YYYY-MM-DD',
  type: 'expense' | 'income',
  category: string,   // 下記カテゴリーのいずれか
  amount: number,       // 円
  memo: string,
  createdAt: number       // Date.now()
}
```

カテゴリー:
- 支出: `食費` `日用品` `交通費` `娯楽` `医療` `固定費` `その他`
- 収入: `給与` `副収入` `その他`

## 変更を公開する

`index.html` を編集したら、GitHubにpushすると数分でGitHub Pagesに反映される。

```
git add -A
git commit -m "..."
git push
```
