"
"
"
function! tweetvim#action#search#define()
  return {
        \ 'description'      : 'seach tweets',
        \ 'need_tweet'       : 0,
        \ }
endfunction
"
"
"
function! tweetvim#action#search#execute(tweet, ...)
  let word = input('search word : ', '', 'custom,tweetvim#complete#search')
  if word == ''
    redraw | echo ''
    return
  endif
  call tweetvim#timeline('search', word)
endfunction
