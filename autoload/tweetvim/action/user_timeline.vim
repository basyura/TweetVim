"
"
"
function! tweetvim#action#user_timeline#execute()
  let tweet = b:tweetvim_status_cache[line('.')]
  call tweetvim#timeline('user_timeline', tweet.user.screen_name)
endfunction
