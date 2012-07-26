"
let s:Vital    = vital#of('tweetvim')
let s:DateTime = s:Vital.import('DateTime')
let s:Html     = s:Vital.import('Web.Html')
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
  return s:Html.decodeEntityReference(a:msg)
endfunction
"
"
"
function! tweetvim#util#bufwidth()
  let width = winwidth(0)
  if &l:number || &l:relativenumber
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
