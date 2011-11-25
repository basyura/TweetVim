"
"
"
function! tweetvim#action#remove_favorite#define()
  return {
        \ 'description' : 'remove favorite',
        \ }
endfunction
"
"
"
function! tweetvim#action#remove_favorite#execute(tweet)
  echo a:tweet.user.screen_name . ' ' . a:tweet.text
  if input('remove favorite ? [y/n] : ') != 'y'
    return
  endif
  let ret = tweetvim#request('remove_favorite', a:tweet.id_str)
  redraw
  if has_key(ret, 'errors')
    echohl ErrorMsg | echo ret.errors | echohl None
  else
    echo 'removed favorite'
  endif
endfunction
