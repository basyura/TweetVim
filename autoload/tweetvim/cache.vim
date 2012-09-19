"
let s:cache = {}
"
"
function! tweetvim#cache#get(fname)
  if !has_key(s:cache, a:fname)
    call tweetvim#cache#read(a:fname)
  endif
  return keys(s:cache[a:fname])
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
  if !has_key(s:cache, a:fname)
    call tweetvim#cache#read(a:fname)
  endif
  let size = len(s:cache[a:fname])
  let path = g:tweetvim_config_dir . '/' . a:fname
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
  let values = sort(keys(s:cache[a:fname]))
  try
    call writefile(values, path)
    call tweetvim#hook#fire('write_' . a:fname, values)
  catch
    echomsg "failed to write tweetvim's " . a:fname  " cache"
  endtry
endfunction
