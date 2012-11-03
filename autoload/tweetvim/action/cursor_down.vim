"
"
"
function! tweetvim#action#cursor_down#define()
  return {
        \ 'description'      : 'cursor down (skip separator)',
        \ 'source__is__list' : 0,
        \ 'need_tweet'       : 0,
        \ }
endfunction
"
"
"
function! tweetvim#action#cursor_down#execute(tweet)
  while 1
    :execute "normal! \<Down>"
    if getline(".") !~ '^  ' && (!tweetvim#util#isCursorOnSeprator() || line(".") == line("$"))
      break
    endif
  endwhile
endfunction
