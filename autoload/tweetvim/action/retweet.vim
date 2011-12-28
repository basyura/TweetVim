"
"
"
function! tweetvim#action#retweet#define()
  return {
        \ 'description' : 'retweet',
        \ }
endfunction
"
"
"
function! tweetvim#action#retweet#execute(tweet)
  echo a:tweet.user.screen_name . ' ' . tweetvim#util#unescape(a:tweet.text)
  if input('retweet ? [y/n] : ') != 'y'
    return
  endif
  let ret = tweetvim#request('retweet', a:tweet.id_str)
  redraw
  if has_key(ret, 'errors')
    echohl ErrorMsg | echo ret.errors | echohl None
  else
    echo 'retweeted'
  endif
endfunction
