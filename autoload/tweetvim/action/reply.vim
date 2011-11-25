"
"
"
function! tweetvim#action#reply#execute(...)
  let line = line('.')
  if !has_key(b:tweetvim_status_cache, line)
    return
  endif
  let tweet = b:tweetvim_status_cache[line]
  let param = {'in_reply_to_status_id' : tweet.id_str}
  call tweetvim#say#open('@' . tweet.user.screen_name . ' ', param)
endfunction
