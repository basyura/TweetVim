"
"
"
function! tweetvim#action#favstar#define()
  return {
        \ 'description' : 'show favstar',
        \ }
endfunction
"
"
"
function! tweetvim#action#favstar#execute(tweet)

  if !exists(":FavStar")
    echo "you must install mattn/favstar-vim (https://github.com/mattn/favstar-vim)"
    return
  endif

  let tweet = a:tweet

  let name = has_key(tweet, 'retweeted_status') ? tweet.retweeted_status.user.screen_name : tweet.user.screen_name
  let id   = has_key(tweet, 'retweeted_status') ? tweet.retweeted_status.id_str : tweet.id_str

  execute "FavStar" name id
endfunction
