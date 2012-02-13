"
"
"
function! tweetvim#logger#log(msg, ...)
  " check log mode
  if !get(g:, 'tweetvim_log', 0)
    return
  endif
  " check module
  if !exists('s:loaded_module_log')
    if exists('*log#init')
      let s:loaded_module_log = 1
      call log#init('ALL', '~/.tweetvim/log.txt')
      let s:log = log#getLogger('tweetvim')
    else
      let s:loaded_module_log = 0
      echohl Error | echo 'log.vim is not exist.' | echohl None
    endif
  endif
  " check log
  if !s:loaded_module_log
    return
  endif
  " check added param
  if !a:0 
    call s:log.debug(a:msg)
    return
  endif
  " check type of args
  if type(a:1) == 3
    " list
    for n in a:1
      call tweetvim#logger#log(a:msg, n)
    endfor
  elseif type(a:1) == 4
    " dictionary
    for n in keys(a:1)
      call s:log.debug(a:msg .  string(n) . ' : ' .  string(a:1[n]))
    endfor
  else
    call s:log.debug(a:msg . string(a:1))
  endif
endfunction
