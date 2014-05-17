"
"
let s:hooks = {
      \ 'write_screen_name' : [],
      \ 'write_hash_tag'    : [],
      \ 'notify_fav'        : [],
      \ 'notify_unfav'      : [],
      \ 'notify_retweet'    : [],
      \ 'notify_mention'    : [],
      \ }
"
"
"
function! tweetvim#hook#add(name, func_name)
  if !has_key(s:hooks, a:name)
    echoerr 'tweetvim error no hook : ' . a:name
    return
  endif
  if index(s:hooks[a:name], a:func_name) < 0
    call add(s:hooks[a:name], a:func_name)
  else
    echoerr 'tweetvim error duplicated function : ' . a:func_name . ' in hook ' . a:name
  endif
endfunction
"
"
"
function! tweetvim#hook#remove(name, func_name)
  if !has_key(s:hooks, a:name)
    echoerr 'tweetvim error no hook : ' . a:name
    return
  endif
  let idx = index(s:hooks[a:name], a:func_name)
  if idx >= 0
    call remove(s:hooks[a:name], idx)
  else
    echomsg 'tweetvim message no function : ' . a:func_name . ' in hook' . a:name
  endif
endfunction
"
"
"
function! tweetvim#hook#fire(name, ...)
  if !has_key(s:hooks, a:name)
    echoerr 'tweetvim error no hook : ' . a:name
    return
  endif
  for func_name in s:hooks[a:name]
    call call(func_name, a:000)
  endfor
endfunction
