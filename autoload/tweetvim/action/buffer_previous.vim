"
"
"
function! tweetvim#action#buffer_previous#define()
  return {
        \ 'description'      : 'load previous buffer',
        \ 'source__is__list' : 0,
        \ 'need_tweet'       : 0,
        \ }
endfunction
"
"
"
function! tweetvim#action#buffer_previous#execute(tweet, ...)
  call tweetvim#buffer#previous()
endfunction
