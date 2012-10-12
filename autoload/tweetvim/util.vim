"
let s:Vital    = vital#of('tweetvim')
let s:DateTime = s:Vital.import('DateTime')
let s:Html     = s:Vital.import('Web.Html')
let s:List     = s:Vital.import('Data.List')
"
"
"
function! tweetvim#util#uniq(list)
  return s:List.uniq(a:list)
endfunction
"
"
"
function! tweetvim#util#format_date(date)
  if a:date =~ ','
    let date_time = s:DateTime.from_format(a:date,'%a, %d %b %Y %H:%M:%S %z', 'C')
  else
    let date_time = s:DateTime.from_format(a:date,'%a %b %d %H:%M:%S %z %Y', 'C')
  endif
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
  let max = tweetvim#util#bufwidth()
  " FIXME
  if g:tweetvim_display_icon
    let max -= 2
  endif

  let sep = ""
  while len(sep) < max
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
"
"
"
function! tweetvim#util#isCursorOnSeprator()
  let name = synIDattr(synID(line('.'),col('.'),1),'name')
  return name == 'tweetvim_separator' || name == 'tweetvim_separator_title'
endfunction
