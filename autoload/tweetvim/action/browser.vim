"
"
"
function! tweetvim#action#browser#execute(tweet)
  let url   = 'https://twitter.com/\#!/' . a:tweet.user.screen_name . '/status/' . a:tweet.id_str
  execute "OpenBrowser " . url
endfunction
