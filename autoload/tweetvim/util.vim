"
let s:Vital    = vital#of('tweetvim')
let s:DateTime = s:Vital.import('DateTime')
"
"
"
function! tweetvim#util#format_date(date)
 let date_time = s:DateTime.from_format(a:date,'%a %b %d %H:%M:%S %z %Y', 'C')
 return date_time.strftime("%m/%d %H:%M")
endfunction
"
"
"
function! tweetvim#util#today()
 return s:DateTime.now().strftime('%m/%d')
endfunction
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
  while len(sep) < tweetvim#util#bufwidth()
    let sep .= a:s
  endwhile
  return sep
endfunction
"
"
"
function! tweetvim#util#unescape(msg)
  let msg = a:msg
  let msg = substitute(msg, '&quot;' , '"', 'g')
  let msg = substitute(msg, '&lt;'   , '<', 'g')
  let msg = substitute(msg, '&gt;'   , '>', 'g')
  let msg = substitute(msg, '&#039;' , "'", 'g')
  return msg
endfunction
"
"
"
function! tweetvim#util#bufwidth()
  let width = winwidth(0)
  if &l:number
    let width = width - (&numberwidth + 1)
  endif
  return width
endfunction
"
"
"
function! tweetvim#util#trim(msg)
  let msg = a:msg
  let msg = substitute(msg, '^\s\+' , '' , '')
  let msg = substitute(msg, '\s\+$' , '' , '')
  return msg
endfunction
