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
  let tweet = a:tweet
  echo tweet.user.screen_name . ' ' . tweetvim#util#unescape(tweet.text)
  let ret = tweetvim#request('remove_favorite', tweet.id_str)
  redraw
  if has_key(ret, 'errors')
    echohl ErrorMsg | echo ret.errors | echohl None
  else
    let  tweet.favorited = 0
    call tweetvim#buffer#replace(line("."), tweet)
    echo 'removed favorite'
  endif
endfunction
