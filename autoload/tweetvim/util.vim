"
let s:Vital    = vital#of('tweetvim')
let s:DateTime = s:Vital.import('DateTime')
let s:Html     = s:Vital.import('Web.HTML')
let s:Http     = s:Vital.import('Web.HTTP')
let s:List     = s:Vital.import('Data.List')
let s:File     = s:Vital.import('System.File')
let s:Filepath = s:Vital.import('System.Filepath')
"
"
"
function! tweetvim#util#uniq(list)
  return s:List.uniq(a:list)
endfunction

"
"
"
function! tweetvim#util#clear_icon(...)
  let name = a:0 ? a:1 . '.ico' : ''
  let path = s:Filepath.join(g:tweetvim_config_dir, 'ico', name)
  call s:File.rmdir(path, 'r')
  if !isdirectory(g:tweetvim_config_dir . '/ico')
    call mkdir(g:tweetvim_config_dir . '/ico', 'p')
  endif
endfunction

"
"
"
function! tweetvim#util#format_date(date)
  try
    if a:date =~ ','
      let date_time = s:DateTime.from_format(a:date,'%a, %d %b %Y %H:%M:%S %z', 'C')
    else
      let date_time = s:DateTime.from_format(a:date,'%a %b %d %H:%M:%S %z %Y', 'C')
    endif
    return date_time.strftime("%m/%d %H:%M")
  catch
    return a:date
  endtry
endfunction
"
"
"
function! tweetvim#util#today()
  try
    return s:DateTime.now().strftime('%m/%d')
  catch
    return "error"
  endtry
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
function! tweetvim#util#decodeURI(str)
  return s:Http.decodeURI(a:str)
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
  let width = winwidth(0) - &foldcolumn
  if &l:number || &l:relativenumber
    let width = width - (&numberwidth + 1) - (&foldcolumn)
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
"
" from suddendeath.vim - MIT License
"
function tweetvim#util#sudden_death(str)
  let width = s:str_to_mb_width(a:str) + 2
  let top = '＿' . join(map(range(width), '"人"'),'') . '＿'
  let content = '＞　' . a:str . '　＜'
  let bottom = '￣' . join(map(range(width), '"Ｙ"'),'') . '￣'
  return join([top, content, bottom], "\n")
endfunction
"
" from suddendeath.vim - MIT License
"
function! s:str_to_mb_width(str)
  return strlen(substitute(substitute(a:str, "[ -~｡-ﾟ]", 's', 'g'), "[^s]", 'mm', 'g')) / 2
endfunction
"
