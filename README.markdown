TweetVim
========

twitter client for vim
http://www.vim.org/scripts/script.php?script_id=4532

![img](http://cdn-ak.f.st-hatena.com/images/fotolife/b/basyura/20130418/20130418204049.png)

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
- [(favstar-vim)](https://github.com/mattn/favstar-vim)
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

### バージョンを表示する

    :TweetVimVersion

### アカウントを追加する

    :TweetVimAddAccount

### アカウントを変更する

    :TweetVimSwitchAccount {screen_name}

### ホームタイムラインを表示する。

    :TweetVimHomeTimeline

### Mention を表示する

    :TweetVimMentions

### リストを表示する

    :TweetVimListStatuses vim

### ユーザのタイムラインを表示する

    :TweetVimUserTimeline basyura

### ツイート用バッファを開く

    :TweetVimSay

### ユーザーストリーム

    :TweetVimUserStream vim emacs lang:ja

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
    nmap <silent> <buffer> <leader>F  <Plug>(tweetvim_action_favstar)
    nmap <silent> <buffer> <Leader><Leader>  <Plug>(tweetvim_action_reload)

    nmap <silent> <buffer> ff  <Plug>(tweetvim_action_page_next)
    nmap <silent> <buffer> bb  <Plug>(tweetvim_action_page_previous)

    nmap <silent> <buffer> H  <Plug>(tweetvim_buffer_previous)
    nmap <silent> <buffer> L  <Plug>(tweetvim_buffer_next)

    nmap <silent> <buffer> j <Plug>(tweetvim_action_cursor_down)
    nmap <silent> <buffer> k <Plug>(tweetvim_action_cursor_up)

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

### アカウントの変更

    :Unite tweetvim/account

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

- block           - block this user
- browser         - open tweet with browser
- expand_url      - expand url
- favorite        - favorite tweet
- favstar         - show favstar
- favstar_browser - open favstar site by browser
- follow          - follow user
- in_reply_to     - show conversation
- list            - add user to list
- open_links      - open links in tweet
- qt              - quote tweet
- remove_favorite - remove favorite
- remove_status   - remove status
- reply           - reply
- retweet         - retweet
- search          - seach tweets
- unfollow        - unfollow user
- user_timeline   - show user timeline


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
- アカウントを変更したい => :TweetVimSwitchAccount {screen_name}
- Unite でアカウントを変更したい => :Unite tweetvim/account

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

発言用のバッファを開く際のコマンドを指定

    let g:tweetvim_open_say_cmd = 'botright split'

アイコン表示 (ImageMagick が必要)

    let g:tweetvim_display_icon = 1

tweetvim_say バッファを開いた際にフッタ(メッセージ)を表示する

    let g:tweetvim_footer = ''

tweetvim_say バッファにアカウント名を差し込む

    let g:tweetvim_say_insert_account = 0
    
    [basyura] :
    上記は触らなければ発言時に削除する。文字数カウントの考慮はない。

セパレータの表示/非表示

    let g:tweetvim_display_separator = 1

空文字セパレータを表示

    let g:tweetvim_empty_separator = 0

    g:tweetvim_display_separator と排他的に動作

release v2.5 2016.01.16
-----------------------

- highlight の改善 thanks! rhysd, pocke, 839
- エラーメッセージの改善 thanks! rhysd
- ドキュメントの改善 thanks! todashuta, ryunix
- バッファ名設定 (`g:tweetvim_buffer_name`) の追加 thanks! kamichidu
- tweetvim say バッファでのユーザ名補完候補のソート改善 thanks! rhysd
- replay-to-all アクションでの宛先が重複しないように改善 thanks! rhysd
- foldcolumn 指定時のセパレータの長さを改善 thanks! Chris Weyl
- ツイート内のツイート url サポート

release v2.4 2014.07.06
-----------------------

- イベント通知 hook を追加 thanks! tokoro10g
- UserStream に fav を表示
- regexpengine = 1 or vim 7.3 のときは url を考慮せずに文字数でカウントする
- typo とか hilight の改善、url 展開の改善とかたくさん thanks! rhysd
- say バッファでタグメンションをハイライト thanks! thinca
- vital のアップデート

release v2.3 2014.04.20
-----------------------

- 文字数カウント時に url 短縮を考慮 thanks! thinca
- user stream の status_withheld  でエラーになっていたのを修正 thanks! ompugao
- TweetVimUserStream! で track ワードにかかるツイートだけを表示
- 140 文字を超えた場合にポストするかを確認する
- list へのメンバ追加がこけていたのを修正
- vital のアップデート
- numberwith 指定時のレイアウト修正 thanks! itchyny
- readme の改善 thanks! Masahiro Saito 
- 該当ツイート周辺のツイートを表示する around action を追加

release v2.2 2013.08.21
-----------------------

- TweetVimClearIcon {screen_name} で screen_name 指定 or 全部のアイコンを ~/.tweetvim/ico から削除するコマンドを追加
- vital の最新化 thanks! rhysd
- list の取得ができていなかった・・・遅延取得するように修正 (TweetVimSwitchAccount が早くなった)
- TweetVimAccessToken で呼び出す関数名が間違っていたのを修正 thanks! alpaca-tc
- buffer を silent で開く
- userstream の際の sudden_death 表示時に呼び出す関数名が間違っていたのを修正 thanks! rhysd
- userstream の際に <Leader><Leader> で再接続する
- userstream の際に disconnect 通知でエラー表示されていたのを修正 thanks! ompugao
- <leader>s で userstream のバッファに戻るマッピングを追加
- R で全員に返信するマッピングを追加 thanks! ompugao
- userstream に direct message を流す thanks! ompugao
- userstream で filter が効いていなかったのを修正 thanks! rhysd
- ツイートが無い場合に再接続するまでまつ時間を設定する g:tweetvim_reconnect_seconds を追加

release v2.0 2013.04.18
-----------------------

- icon 表示の際に複数行表示できていなかったのを修正

release v1.9 2013.02.06
-----------------------

- api 1.1 対応
- t.co のデフォルト展開設定を追加 (g:tweetvim_expand_t_co)。default = 0
- favstar のステータス表示とブラウザ表示を追加
- 複数行対応

release v1.8 2012.11.03
-----------------------

- RT でツイートが省略されないように修正 by rhysd
- API の変更
  - tweetvim#current_account → tweetvim#account#current
  - tweetvim#add_hook → tweetvim#hook#add
  - tweetvim#complete_XXXX → tweetvim#complete#XXXX
- inoremap C-CR でツイートするようにしてみた
- j or k でセパレータを飛ばして移動するようにした
- 検索の際に日時が出ていなかったのを修正
- :TweetVimVersion or tweetvim#version() でバージョンを取得できるようにしてみた
- 非同期のポスト (g:tweetvim_async_post)
  - twibill.vim の最新化が必要

release v1.7 2012.08.31
------------------------

- マルチアカウント対応
- :TweetVimSay コマンドにアカウントが渡せるようにした。その際はアカウントが変更される
- :TweetVimAddAccount を追加。アカウントを追加
- :TweetVimSwitchAccount を追加。カウントの変更
- :Unite tweetvim/account でアカウントの変更
- g:tweetvim_open_buffer_cmd を追加 (デフォルトを botright split に変更)
- g:tweetvim_say_insert_account を追加
  - 発言時のアカウントを tweetvim_say バッファに差し込む(いじらなければツイートはされない)

### g:tweetvim_config_dir 配下のディレクトリ構成を変更

before

    g:tweetvim_config_dir/token

after

    g:tweetvim_config_dir/accounts/
                          screen_name1/token
                          screen_name2/token
                          screen_name3/token

フォルダ構成は自動的に修正します。エラーが出る場合は、 TweetVimMigration を実行してみること。
回復しない場合は上記のディレクトリ構成に手動で変更すること。

release v1.6 2012.08.03
-----------------------

- scriptencoding utf-8
- vital の最新化
- tweet の間のセパレータ(---)を表示・非表示できる g:tweetvim_display_separator を追加
- g:tweetvim_footer を追加 - http://d.hatena.ne.jp/osyo-manga/20120711/1341940747
- g:tweetvim_display_icon を追加
- ハッシュタグの自動挿入 (g:tweetvim_footer)

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

Vitalize
--------

Vitalize --name=tweetvim DateTime Web.HTML System.Filepath System.File
