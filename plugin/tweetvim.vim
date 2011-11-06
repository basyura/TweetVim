let s:consumer_key    = '8hht6fAi3wU47cwql0Cbkg'
let s:consumer_secret = 'sbmqcNqlfwpBPk8QYdjwlaj0PIZFlbEXvSxxNrJDcAU'

let s:config_path = expand('~/.tweetvim')

let s:buf_name = '[tweetvim]'


command! TweetVimAccessToken  :call <SID>access_token()
command! TweetVimHomeTimeline :call <SID>home_timeline()

function! s:access_token()

  if filereadable(s:config_path)
    return readfile(s:config_path)
  endif

  let ctx = twibill#access_token({
              \ 'consumer_key'    : s:consumer_key,
              \ 'consumer_secret' : s:consumer_secret,
              \ })
  let tokens = [ctx.access_token, ctx.access_token_secret]

  call writefile(tokens , s:config_path)

  return tokens
endfunction

function! s:config()
  let tokens = s:access_token()
  return {
    \ 'consumer_key'        : s:consumer_key ,
    \ 'consumer_secret'     : s:consumer_secret ,
    \ 'access_token'        : tokens[0] ,
    \ 'access_token_secret' : tokens[1] ,
    \ }
endfunction

function! s:twibill()
  let t = twibill#new(s:config())
  return t
  if exists('s:twibill_cache')
    return s:twibill_cache
  endif
  let s:twibill_cache = twibill#new(s:config())
  return s:twibill_cache
endfunction

let s:cache = []

function! s:home_timeline()
  let start = reltime()
  
  let param = {}
  if exists('s:since_id')
    let param["since_id"] = s:since_id
  endif

  "let xml = s:twibill().list_statuses('basyura', 'friends', {'per_page' : 50}) 
  "let xml = s:twibill().list_statuses('basyura', 'all') 
  let xml = s:twibill().home_timeline() 
  "let xml = s:twibill().mentions()

  "let bufno = bufexists(s:buf_name)
  "if bufno != 0 
  let bufno = s:bufnr()
  if bufno > 0
    execute 'buffer ' . bufno
  else
    execute 'edit! ' . s:buf_name
  endif

  setlocal noswapfile
  setlocal modifiable
  setlocal buftype=nofile
  setfiletype tweetvim

  silent %delete _

  let nodes = xml.childNodes('status')
  if len(nodes) != 0
    let s:since_id = nodes[0].find('id').value()
  endif
  call extend(s:cache, nodes, 0)


  for status in s:cache
    call append(line('$') - 1, s:separator('_'))
    let str  = s:padding(status.find('screen_name').value(), 15) . ' :' 
    let str .= s:unescape(status.find('text').value())
    let str .= ' - ' . status.find('created_at').value()
    let str .= ' [' . status.find('id').value() . ']'
    call append(line('$') - 1, str)
  endfor
  call append(0, '[tweetvim] ' . bufno . ' - home timeline (' . split(reltimestr(reltime(start)))[0] . ' [s])')
  :0
  setlocal nomodified
  setlocal nomodifiable
endfunction

function! s:bufnr()
  return bufexists(substitute(substitute(s:buf_name, '[', '\\[', 'g'), ']', '\\]', 'g') . '$')
endfunction

function! s:unescape(msg)
  let msg = a:msg
  let msg = substitute(msg, '&quot;', '"', 'g')
  let msg = substitute(msg, '&lt;'  , '<', 'g')
  let msg = substitute(msg, '&gt;'  , '>', 'g')
  return msg
endfunction

function! s:padding(msg, length)
  let msg = a:msg
  while len(msg) < a:length
    let msg = msg . ' '
  endwhile
  return msg
endfunction

function! s:separator(s)
  let sep = ""
  while len(sep) + 4 < winwidth(0)
    let sep .= a:s
  endwhile
  return sep
endfunction
