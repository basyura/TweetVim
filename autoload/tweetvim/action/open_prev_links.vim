"
"
"
function! tweetvim#action#open_prev_links#define()
  return {
        \ 'description' : 'open previous tweet links',
        \ 'source__is__list' : 0,
        \ 'need_tweet'       : 0,
        \ }
endfunction
"
"
"
function! tweetvim#action#open_prev_links#execute(tweet)
  call tweetvim#action#cursor_up#execute({})
  let tweet = b:tweetvim_status_cache[line(".")]
  call tweetvim#action#open_links#execute(tweet)
  call tweetvim#action#cursor_down#execute({})
endfunction
