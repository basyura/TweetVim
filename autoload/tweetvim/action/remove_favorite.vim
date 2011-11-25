"
"
"
function! tweetvim#action#remove_favorite#execute()
  let tweet = b:tweetvim_status_cache[line('.')]
  echo tweet.user.screen_name . ' ' . tweet.text
  if input('remove favorite ? [y/n] : ') != 'y'
    return
  endif
  let ret = tweetvim#request('remove_favorite', tweet.id_str)
  redraw
  if has_key(ret, 'errors')
    echohl ErrorMsg | echo ret.errors | echohl None
  else
    echo 'removed favorite'
  endif
endfunction
