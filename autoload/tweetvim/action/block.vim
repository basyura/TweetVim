"
"
"
function! tweetvim#action#block#define()
  return {
        \ 'description' : 'block this user',
        \ }
endfunction
"
"
"
function! tweetvim#action#block#execute(tweet)
  let tweet = a:tweet
  echo tweet.user.screen_name . ' ' . tweetvim#util#unescape(tweet.text)
  if input('block this user ? [y/n] : ') != 'y'
    return
  endif
  let ret = tweetvim#request('block', tweet.user.screen_name)
  redraw
  if has_key(ret, 'errors')
    echohl ErrorMsg | echo ret.errors | echohl None
  else
    let tweet.text = 'blocked this user'
    call tweetvim#buffer#replace(line("."), tweet)
    echo 'blocked ' . tweet.user.screen_name
  endif
endfunction
