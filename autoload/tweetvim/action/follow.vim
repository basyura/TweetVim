"
"
"
function! tweetvim#action#follow#define()
  return {
        \ 'description' : 'follow user',
        \ }
endfunction
"
"
"
function! tweetvim#action#follow#execute(tweet)
  let tweet = a:tweet
  echo tweet.user.screen_name . ' ' . tweetvim#util#unescape(tweet.text)
  if input('follow ? [y/n] : ') != 'y'
    return
  endif
  let ret = tweetvim#request('follow', tweet.user.screen_name)
  redraw
  if has_key(ret, 'errors')
    echohl ErrorMsg | echo ret.errors | echohl None
  else
    echo 'followed ' . tweet.user.screen_name
  endif
endfunction
