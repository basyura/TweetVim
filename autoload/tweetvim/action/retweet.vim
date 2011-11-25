"
"
"
function! tweetvim#action#retweet#execute()
  let tweet = b:tweetvim_status_cache[line('.')]
  echo tweet.user.screen_name . ' ' . tweet.text
  if input('retweet ? [y/n] : ') != 'y'
    return
  endif
  let ret = tweetvim#request('retweet', tweet.id_str)
  redraw
  if has_key(ret, 'errors')
    echohl ErrorMsg | echo ret.errors | echohl None
  else
    echo 'retweeted'
  endif
endfunction
