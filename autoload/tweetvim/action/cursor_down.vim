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
    if !s:is_skipable()
      break
    endif
  endwhile
endfunction

function! s:is_skipable()

  if line(".") == line("$")
    return 0
  endif

  let line = getline(".")

  if line == ''
    return 1
  endif

  if line !~ '^  ' && (!tweetvim#util#isCursorOnSeprator() || line(".") == line("$"))
    return 0
  endif

  return 1
endfunction
