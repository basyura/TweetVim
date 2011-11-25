"
"
"
function! tweetvim#action#favorite#execute()
  let tweet = b:tweetvim_status_cache[line('.')]
  echo tweet.user.screen_name . ' ' . tweet.text
  if input('favorite ? [y/n] : ') != 'y'
    return
  endif
  let ret = tweetvim#request('favorite', tweet.id_str)
  redraw
  if has_key(ret, 'errors')
    echohl ErrorMsg | echo ret.errors | echohl None
  else
    echo 'favorited'
  endif
endfunction
