"
"
"
function! tweetvim#action#buffer_previous_stream#define()
  return {
        \ 'description'      : 'load previous userstream buffer',
        \ 'source__is__list' : 0,
        \ 'need_tweet'       : 0,
        \ }
endfunction
"
"
"
function! tweetvim#action#buffer_previous_stream#execute(tweet, ...)
  call tweetvim#buffer#previous_stream()
endfunction
