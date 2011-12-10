"
"
"
function! tweetvim#action#buffer_next#define()
  return {
        \ 'description'      : 'load next buffer',
        \ 'source__is__list' : 0,
        \ 'need_tweet'       : 0,
        \ }
endfunction
"
"
"
function! tweetvim#action#buffer_next#execute(tweet, ...)
  call tweetvim#buffer#next()
endfunction
