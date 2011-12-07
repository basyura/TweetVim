
# TweetVim

twitter client for vim

## dependent

- [webapi-vim](https://github.com/mattn/webapi-vim)
- [open-browser.vim](https://github.com/tyru/open-browser.vim)
- [twibill.vim](https://github.com/basyura/twibill.vim)
- [(bitly.vim)](https://github.com/basyura/bitly.vim)

## HowTo

### verify

認証されていない場合はコマンド実行時にブラウザが起動して PIN を表示。

    :TweetVimHomeTimeline
	  
    > now launched your browser to authenticate
    > Enter Twitter OAuth PIN:

PIN を入力すると認証完了。
認証時に発行された AccessToken と AccessTokenSecret が以下に保存される。

    ~/.tweetvim/token

### サポートコマンド

#### ホームタイムラインを表示する。

    :TweetVimHomeTimeline

#### Mention を表示する

    :TwetVimMentions

#### リストを表示する

    :TweetVimListStatuses vim

#### ユーザのタイムラインを表示する

    :TweetVimUserTimeline basyura

#### ツイート用バッファを開く

    :TweetVimSay

メッセージ入力後、ノーマルモードの Enter でツイート。

## TODO

- バッファの使い回しがおかしい。増える。
- 新規ツイートが分かるように
- タイムラインの更新中が分かるように
- filter
- user 情報の表示
- list への追加削除
- list の作成

### 済

- コマンドの補完
- リスト補完
- screen_name ファイルの更新チェック
- メッセージバッファでのユーザ名補完
- follow unfollow
- history of tweets ( unite & command )
- buffer の進戻るの改善
- ページ遷移して戻った時にタイトルのページが戻らない (バッファに保持してるから)
- 次ページ、前ページ
- fav したときに ★ を付ける
