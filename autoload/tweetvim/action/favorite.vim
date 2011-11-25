"
"
"
function! tweetvim#action#favorite#define()
  return {
        \ 'description' : 'favorite tweet',
        \ }
endfunction
"
"
"
function! tweetvim#action#favorite#execute(tweet)
  echo a:tweet.user.screen_name . ' ' . a:tweet.text
  if input('favorite ? [y/n] : ') != 'y'
    return
  endif
  let ret = tweetvim#request('favorite', a:tweet.id_str)
  redraw
  if has_key(ret, 'errors')
    echohl ErrorMsg | echo ret.errors | echohl None
  else
    echo 'favorited'
  endif
endfunction
