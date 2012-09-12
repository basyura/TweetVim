"
"
let s:hooks = {
      \ 'write_screen_name' : [],
      \ 'write_hash_tag'    : [],
      \ }
"
"
"
function! tweetvim#hook#add(name, func_name)
  if !has_key(s:hooks, a:name)
    echoerr 'tweetvim error no hook : ' . a:name
    return
  endif
  call add(s:hooks[a:name], a:func_name)
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
