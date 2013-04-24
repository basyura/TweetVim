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
  let tweet = a:tweet
  echo tweet.user.screen_name . ' ' . tweetvim#util#unescape(tweet.text)
  let ret = tweetvim#request('favorite', tweet.id_str)
  redraw
  if has_key(ret, 'errors')
    echohl ErrorMsg | echo ret.errors | echohl None
  else
    let  tweet.favorited = 1
    call tweetvim#buffer#replace(line("."), tweet)
    echo 'favorited'
  endif
endfunction
