"
let s:cache = {'screen_name' : {}}
"
"
"
function! tweetvim#cache#get(key)
  return s:cache[a:key]
endfunction
"
"
"
function! tweetvim#cache#read(fname)
  let path = g:tweetvim_config_dir . '/' . a:fname
  if !filereadable(path)
    call writefile([], path)
  endif
  " cache
  let cache = {}
  for name in readfile(path)
    if name != ""
      let cache[name] = 1
    endif
  endfor

  let s:cache[a:fname] = cache
  let s:cache[a:fname . '_ftime'] = getftime(path)
endfunction
"
"
"
function! tweetvim#cache#write(fname, list)
  let path  = g:tweetvim_config_dir . '/' . a:fname
  let cache = s:cache[a:fname]
  let size  = len(cache)
  " check local change
  if filereadable(path) && getftime(path) != s:cache[a:fname . '_ftime']
    call tweetvim#cache#read(a:fname)
  endif
  " update buffer cache
  for name in a:list
    let s:cache[a:fname][name] = 1
  endfor
  " check updatable
  if size == len(s:cache[a:fname])
    return
  endif
  " TODO : merge if local file is updated
  call writefile(sort(keys(s:cache[a:fname])), path)
endfunction
