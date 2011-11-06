"
"
"
function! tweetvim#util#padding(msg, length)
  let msg = a:msg
  while len(msg) < a:length
    let msg = msg . ' '
  endwhile
  return msg
endfunction
"
"
"
function! tweetvim#util#separator(s)
  let sep = ""
  while len(sep) + 4 < winwidth(0)
    let sep .= a:s
  endwhile
  return sep
endfunction
"
"
"
function! tweetvim#util#unescape(msg)
  let msg = a:msg
  let msg = substitute(msg, '&quot;', '"', 'g')
  let msg = substitute(msg, '&lt;'  , '<', 'g')
  let msg = substitute(msg, '&gt;'  , '>', 'g')
  return msg
endfunction
