# かんたん家計簿 (kakeibo-app)

ブラウザだけで完結する家計簿アプリ。`index.html` を開くだけで使える。データはブラウザの localStorage に保存される（外部送信なし）。

## 使い方

1. `index.html` をダブルクリック（またはブラウザにドラッグ）して開く
2. フォームから収入・支出を入力して「記録する」

## Claude に話しかけて自動入力する

この作業ディレクトリで Claude Code に「ランチ 1200円」のようにメッセージを送ると、Claude が内容を解析して自動で記録を追加する。

### 仕組み

- Claude はメッセージから日付・金額・カテゴリー・メモを読み取り、[data/entries.js](data/entries.js) の `window.CLAUDE_ENTRIES` 配列に1件追記する
- `index.html` は起動時にこのファイルを読み込み、まだ取り込んでいないエントリーを localStorage にマージする
- そのため **チャットでエントリーを追加したあとは、アプリを開き直す（またはリロードする）と反映される**（開きっぱなしのタブには自動反映されない）
- 一度取り込んだIDは記憶されるので、アプリ側で削除しても再度復活することはない

### エントリーの形式

```js
{
  id: 'claude-<timestamp>-<random>', // 'claude-' で始まる一意なID
  date: 'YYYY-MM-DD',
  type: 'expense' | 'income',
  category: string,   // 下記カテゴリーのいずれか
  amount: number,      // 円
  memo: string,
  createdAt: number     // Date.now()
}
```

カテゴリー:
- 支出: `食費` `日用品` `交通費` `娯楽` `医療` `固定費` `その他`
- 収入: `給与` `副収入` `その他`

`data/entries.js` は手動で編集しない（Claude が追記する）。
