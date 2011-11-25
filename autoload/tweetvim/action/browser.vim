"
"
"
function! tweetvim#action#browser#execute()
  let tweet = b:tweetvim_status_cache[line('.')]
  let url   = 'https://twitter.com/\#!/' . tweet.user.screen_name . '/status/' . tweet.id_str
  execute "OpenBrowser " . url
endfunction
