"
"
"
function! tweetvim#action#favstar_browser#define()
  return {
        \ 'description' : 'open favstar site by browser',
        \ }
endfunction
"
"
"
function! tweetvim#action#favstar_browser#execute(tweet)

  let tweet = a:tweet

  let name = has_key(tweet, 'retweeted_status') ? tweet.retweeted_status.user.screen_name : tweet.user.screen_name
  let id   = has_key(tweet, 'retweeted_status') ? tweet.retweeted_status.id_str : tweet.id_str

  let url = 'http://favstar.fm/users/' . name . '/status/' . id
  execute "OpenBrowser " . url
endfunction
