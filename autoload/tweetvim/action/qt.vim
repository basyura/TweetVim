"
"
"
function! tweetvim#action#qt#execute()
  let tweet = b:tweetvim_status_cache[line('.')]
  let text  = ' QT @' . tweet.user.screen_name . ':' . tweet.text
  let param = {'in_reply_to_status_id' : tweet.id_str}
  call tweetvim#say#open(text, param)
  execute "normal 0"
endfunction
