
TweetVim
========

twitter client for vim

License
-------

MIT License

Requires
--------

- [open-browser.vim](https://github.com/tyru/open-browser.vim)
- [twibill.vim](https://github.com/basyura/twibill.vim)
- [(webapi-vim)](https://github.com/mattn/webapi-vim)
- [(unite-outline)](https://github.com/h1mesuke/unite-outline)
- [(bitly.vim)](https://github.com/basyura/bitly.vim)
- [(unite.vim)](https://github.com/Shougo/unite.vim)
- [cURL](http://curl.haxx.se/)

verify
------

認証されていない場合は、コマンド実行時にブラウザを起動して PIN を表示する。

    :TweetVimHomeTimeline
	  
    > now launched your browser to authenticate
    > Enter Twitter OAuth PIN:

PIN を入力すると認証完了。  
認証時に発行された AccessToken と AccessTokenSecret が以下に保存される。

    ~/.tweetvim/token

~/.tweetvim がファイルとして保存されている場合は削除してから上記を行うこと。

commands
---------------

### ホームタイムラインを表示する。

    :TweetVimHomeTimeline

### Mention を表示する

    :TwetVimMentions

### リストを表示する

    :TweetVimListStatuses vim

### ユーザのタイムラインを表示する

    :TweetVimUserTimeline basyura

### ツイート用バッファを開く

    :TweetVimSay

メッセージ入力後、ノーマルモードの Enter でツイート。

### コマンドラインからツイート

引数が有る場合はそれをメッセージとして、無い場合はプロンプトを表示。

    :TweetVimCommandSay
    or
    :TweetVimCommandSay メッセージ

### カレント行をツイート

    :TweetVimCurrentLineSay

### 検索

    :TweetVimSearch tweetvim

定義済みバッファキーマップ
--------------------------

### タイムライン表示バッファ(tweetvim)

    nmap <silent> <buffer> <CR> <Plug>(tweetvim_action_enter)
    nmap <silent> <buffer> r  <Plug>(tweetvim_action_reply)
    nmap <silent> <buffer> i  <Plug>(tweetvim_action_in_reply_to)
    nmap <silent> <buffer> u  <Plug>(tweetvim_action_user_timeline)
    nmap <silent> <buffer> o  <Plug>(tweetvim_action_open_links)
    nmap <silent> <buffer> q  <Plug>(tweetvim_action_search)
    nmap <silent> <buffer> <leader>f  <Plug>(tweetvim_action_favorite)
    nmap <silent> <buffer> <leader>uf <Plug>(tweetvim_action_remove_favorite)
    nmap <silent> <buffer> <leader>r  <Plug>(tweetvim_action_retweet)
    nmap <silent> <buffer> <leader>q  <Plug>(tweetvim_action_qt)
    nmap <silent> <buffer> <leader>e  <Plug>(tweetvim_action_expand_url)
    nmap <silent> <buffer> <Leader><Leader>  <Plug>(tweetvim_action_reload)

    nmap <silent> <buffer> ff  <Plug>(tweetvim_action_page_next)
    nmap <silent> <buffer> bb  <Plug>(tweetvim_action_page_previous)

    nmap <silent> <buffer> H  <Plug>(tweetvim_buffer_previous)
    nmap <silent> <buffer> L  <Plug>(tweetvim_buffer_next)

    nnoremap <silent> <buffer> a :call unite#sources#tweetvim_action#start()<CR>
    nnoremap <silent> <buffer> t :call unite#sources#tweetvim_timeline#start()<CR>

デフォルトでは、`<leader>` は \ が設定されている

### ツイート用バッファ(tweetvim_say)

    nnoremap <buffer> <silent> q :bd!<CR>
    nnoremap <buffer> <silent> <C-s>      :call <SID>show_history()<CR>
    inoremap <buffer> <silent> <C-s> <ESC>:call <SID>show_history()<CR>
    nnoremap <buffer> <silent> <CR>       :call <SID>post_tweet()<CR>

    inoremap <buffer> <silent> <C-i> <ESC>:call unite#sources#tweetvim_tweet_history#start()<CR>
    nnoremap <buffer> <silent> <C-i> <ESC>:call unite#sources#tweetvim_tweet_history#start()<CR>

Unite インタフェース
--------------------

### タイムライン選択

    :Unite tweetvim

- home_timeline
- mentions
- retweeted_by_me
- retweeted_to_me
- retweets_of_me
- favorites
- @basyura/登録してあるリスト
- @basyura/登録してあるリスト
- ・・・

api を使ってスクリーン名とリスト一覧を取得するので、最初の一回はちょっと遅い。


### アクション選択

tweetvim バッファのみ。  
デフォルトでは a でアクション選択用の Unite が起動する。

- browser         - open tweet with browser
- favorite        - favorite tweet
- follow          - follow user
- in_reply_to     - show conversation
- list            - add user to list
- open_links      - open links in tweet
- qt              - quote tweet
- remove_favorite - remove favorite
- reply           - reply
- retweet         - retweet
- search          - search tweets
- unfollow        - unfollow user
- user_timeline   - show user timeline
- remove_status   - remove status
- expand_url      - expand url

### ツイート歴表示、選択

tweetvim_say バッファのみ。  
デフォルトでは `<C-i>` で歴選択用の Unite が起動する。  
歴は tweetvim_say バッファが閉じられるタイミングでキャッシュされる。  

`<C-s>` で歴を遡って tweetvim_say バッファに表示させることも可

### outline

タイムラインの絞り込み

    :Unite outline

url 短縮
--------

[bitly.vim](https://github.com/basyura/bitly.vim) をインストールしておくと、ツイート用バッファで URL 短縮とタイトルの取得ができる。  
デフォルトのキーマッピング。

    inoremap <buffer> <C-x><C-d> <ESC>:TweetVimBitly<CR>

実行すると以下の内容がツイート用バッファに展開される

    > basyura/TweetVim - GitHub http://bit.ly/t0RQhx

その他
------

タイムラインに表示したスクリーン名のキャッシュ

    ~/.tweetvim/screen_name

使い方
------

### 設定例

    " タイムライン選択用の Unite を起動する
    nnoremap <silent> t :Unite tweetvim<CR>
    " 発言用バッファを表示する
    nnoremap <silent> s           :<C-u>TweetVimSay<CR>
    " mentions を表示する
    nnoremap <silent> <Space>re   :<C-u>TweetVimMentions<CR>
    " 特定のリストのタイムラインを表示する
    nnoremap <silent> <Space>tt   :<C-u>TweetVimListStatuses basyura vim<CR>

    " スクリーン名のキャッシュを利用して、neocomplcache で補完する
    if !exists('g:neocomplcache_dictionary_filetype_lists')
      let g:neocomplcache_dictionary_filetype_lists = {}
    endif
    let neco_dic = g:neocomplcache_dictionary_filetype_lists
    let neco_dic.tweetvim_say = $HOME . '/.tweetvim/screen_name'

### 使用例

- Unite を起動してタイムラインの一覧を表示する => `t`
- タイムラインを選択して表示する
- 最新の内容に更新する => `<leader><leader>`
- リプライする => `r`
- リプライの内容を書きこんで送信する => normal モードで `enter`
- タイムラインの次ページを表示する => `ff`
- タイムラインの前ページを表示する => `bb`
- さっき表示したバッファに戻る => `H`
- やっぱり元のバッファに戻る(進む) => `L`
- 新しく発言する => `s`
- 過去に発言した内容をたどる => `C-s`
- Unite で過去に発言した内容の一覧を表示する => `C-i`
- 発言する => normal モードで `enter`
- 検索してー => `:TweetVimSearch vim`
- このユーザの発言だけ見たい => `u`
- ツイートのやり取りを見たい => `i`
- ふぁぼりたい => `<leader>f`
- ふぁぼ消したい => `<leader>uf`
- リツイートしたい => `<leader>r`
- qt したい => `<leader>q`
- ツイートにあるリンクを全部開きたい => `o`
- Unite で rt とか fav とかしたい => `a`

proxy
-----

会社等から使用したい場合は、以下のプロキシ設定が必要です。
環境変数に設定していない場合は、vimrc に記述してください。

    let $http_proxy   = 'http://xxx.xx.xx:8080'
    let $HTTPS_PROXY  = 'http://xxx.xx.xx:8080'

variables
---------

1 ページあたりのツイート取得件数

    let g:tweetvim_tweet_per_page = 50

表示内容をキャッシュしておく数(バッファを戻る、進むに使用)

    let g:tweetvim_cache_size     = 10

設定情報を保存するディレクトリ

    let g:tweetvim_config_dir     = expand('~/.tweetvim')

タイムラインにリツイートを含める

    let g:tweetvim_include_rts    = 1

source(クライアント名) を表示するオプション

    let g:tweetvim_display_source = 1

ツイート時間の表示・非表示設定 (少しでも表示時間を速くしたい場合)

    let g:tweetvim_display_time   = 1

タイムラインを開く際のコマンドを指定 (edit/split/vsplit)

    let g:tweetvim_open_buffer_cmd = 'edit!'



TODO for v1.6
-------------

- sign を使ってアイコンを表示する
- 非同期のポスト
- ハッシュタグの自動挿入
  - バッファを開いた時に入れる
  - リプライ等では入れない
- POST しようとしてまだ認証してなくて PIN の入力求められて、これをキャンセルしても sending ... ok って出る。
- フィルタリング(NGワード)

release V1.5 2012.06.24
-----------------------

- http://untiny.com/api/ を使用して短縮 url を展開する
- TweetVimSearch で screen_name と hash_tag で補完
- ~/.tweetvim/hash_tag に入力したハッシュタグを出力
- キャッシュしている screen_name と hash_tag を取れる tweetvim#cache#get を追加
- api の結果で errors が返ってきた場合にメッセージ出力

release V1.4 2012.06.01
-----------------------

- doc を書いた
- HTML エンティティの変換に Vital の Web.Html を使うように変更
- unite からリストを選択した時の呼び出しに user.name を使用していたのを user.screen_name に修正
- ツイートした際のエラーは、API のレスポンス内容を表示する (twibill.vim の最新化が必要)

release V1.3 2012.04.13
-----------------------

- webapi-vim の namespace 変更対応
- twibill.vim に webapi-vim を同梱
- remove_status アクションを追加
- 検索結果から in_reply_to を探すときのメッセージ ID チェックを修正
- ライブラリチェック
- http_proxy の設定説明を追加

release v1.2 2012.03.10
-----------------------

- カレント行をツイートする TweetVimCurrentLineSay を追加
- コマンドラインからツイートできる TweetVimCommandSay を追加
- tweetvim バッファで setlocal nolist
- tweetvim_say バッファを開いた時に setlocal nomodified にする
- hilight が上書きされてしまうのを修正
- hilight で link を使う (@delphinus35)
- オリジナル highlight を使う g:tweetvim_original_hi を用意
- タイムラインを開く際のコマンドを指定できるようにした (g:tweetvim_open_buffer_cmd)
- vital の最新化
- 検索時の次ページ、前ページができなかったのを修正(twibill.vim)

release v1.1 2012.01.27
-----------------------

- search action を追加
- block action を追加
- source (クライアント)表示オプション
- 入力可能文字数をステータスラインに表示
- tweetvim_say バッファで改行が入っていたのを削除
- qt の際のカーソル位置を先頭に
- デフォルトキーマッピングの上書きができるように修正
- ハッシュタグの Enter でハッシュタグ検索
- 検索数の初期値(g:tweetvim_tweet_per_page) を 50 → 20 に変更
- バッファの使い回しがおかしくて増殖していたのを修正
- ツイート時間の表示
- 日本語ハッシュタグのハイライト対応

TODO
----

- ツイート単位の activitiy を表示
- TweetVimSearchするアクション : なにを検索対象にするか？
- 新規ツイートが分かるように
- バッファを戻った時にカーソル位置を保持する
- 同じ内容のバッファはキャッシュしない
- list への削除
- list の作成
- 追加済みリストが分かるように

済
--

- list への追加
- タイムラインの更新中が分かるように
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
- user 情報の表示
