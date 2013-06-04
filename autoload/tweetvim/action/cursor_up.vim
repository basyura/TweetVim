"
"
"
function! tweetvim#action#cursor_up#define()
  return {
        \ 'description'      : 'cursor up (skip separator)',
        \ 'source__is__list' : 0,
        \ 'need_tweet'       : 0,
        \ }
endfunction
"
"
"
function! tweetvim#action#cursor_up#execute(tweet)
  while 1
    :execute "normal! \<Up>"
    let line = getline(".")
    if (line !~ '^  ' && line != '' && !tweetvim#util#isCursorOnSeprator()) || line(".") == 1
      break
    endif
  endwhile
endfunction
