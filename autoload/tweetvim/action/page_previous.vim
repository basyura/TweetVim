"
"
"
function! tweetvim#action#page_previous#define()
  return {
        \ 'description'      : 'load previous page',
        \ 'source__is__list' : 0,
        \ }
endfunction
"
"
"
function! tweetvim#action#page_previous#execute(tweet)
  call tweetvim#action#page_next#execute(a:tweet, -1)
endfunction
