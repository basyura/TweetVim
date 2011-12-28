"
"
"
function! tweetvim#action#unfollow#define()
  return {
        \ 'description' : 'unfollow user',
        \ }
endfunction
"
"
"
function! tweetvim#action#unfollow#execute(tweet)
  let tweet = a:tweet
  echo tweet.user.screen_name . ' ' . tweetvim#util#unescape(tweet.text)
  if input('unfollow ? [y/n] : ') != 'y'
    return
  endif
  let ret = tweetvim#request('leave', tweet.user.screen_name)
  redraw
  if has_key(ret, 'errors')
    echohl ErrorMsg | echo ret.errors | echohl None
  else
    echo 'unfollowed ' . tweet.user.screen_name
  endif
endfunction
