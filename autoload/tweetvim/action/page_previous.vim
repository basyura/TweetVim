"
"
"
function! tweetvim#action#page_previous#define()
  return {
        \ 'description'      : 'load previous page',
        \ 'source__is__list' : 0,
        \ 'need_tweet'       : 0,
        \ }
endfunction
"
"
"
function! tweetvim#action#page_previous#execute(tweet)
  " TODO
  call tweetvim#buffer#previous()
  "call tweetvim#action#page_next#execute(a:tweet, -1)
endfunction
