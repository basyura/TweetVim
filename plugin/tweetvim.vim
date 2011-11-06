let s:consumer_key    = '8hht6fAi3wU47cwql0Cbkg'
let s:consumer_secret = 'sbmqcNqlfwpBPk8QYdjwlaj0PIZFlbEXvSxxNrJDcAU'

let s:config_path = expand('~/.tweetvim')

let s:buf_name = '[tweetvim]'
"
"
"
command! TweetVimAccessToken  :call <SID>access_token()
command! TweetVimHomeTimeline :call <SID>timeline('home_timeline')
command! TweetVimMentions     :call <SID>timeline('mentions')
"
"
"
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
"
"
"
function! s:config()
  let tokens = s:access_token()
  return {
    \ 'consumer_key'        : s:consumer_key ,
    \ 'consumer_secret'     : s:consumer_secret ,
    \ 'access_token'        : tokens[0] ,
    \ 'access_token_secret' : tokens[1] ,
    \ }
endfunction
"
"
"
function! s:twibill()
  let t = twibill#new(s:config())
  return t
  if exists('s:twibill_cache')
    return s:twibill_cache
  endif
  let s:twibill_cache = twibill#new(s:config())
  return s:twibill_cache
endfunction
"
"
"
let s:cache = []
"
"
"
function! s:timeline(method)
  let start = reltime()
  
  let param = {}
  if exists('s:since_id')
    let param["since_id"] = s:since_id
  endif

  let xml    = s:twibill()[a:method]()
  let tweets = xml.childNodes()

  for t in tweets
    for key in ['id', 'screen_name', 'text', 'created_at', 'in_reply_to_status_id']
      let t[key] = t.find(key).value()
    endfor
  endfor

  call s:load_timeline(
        \ a:method,
        \ 'home timeline (' . split(reltimestr(reltime(start)))[0] . ' [s])', 
        \ tweets)
endfunction
"
"
"
function! s:load_timeline(method, title, tweets)
  let start = reltime()
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

  let b:tweetvim_method = a:method
  let b:tweetvim_status_cache = {}

  if len(a:tweets) != 0
    let s:since_id = a:tweets[0].id
  endif
  call extend(s:cache, a:tweets, 0)

  for status in s:cache
    let text = status.text
    let text = substitute(text , '' , '' , 'g')
    let text = substitute(text , '\n' , '' , 'g')
    let text = s:unescape(text)

    call append(line('$') - 1, s:separator('-'))
    let str  = s:padding(status.screen_name, 15) . ' : '
    let str .= text
    "let str .= ' - ' . status.find('created_at').value()
    "let str .= ' [' . status.find('id').value() . ']'
    call append(line('$') - 1, str)
    let b:tweetvim_status_cache[line(".")] = status
  endfor

  let title  = '[tweetvim]  - ' . a:title
  let title .= ' (' . split(reltimestr(reltime(start)))[0] . ' [s])'
  let title .= ' : bufno ' . bufno

  call append(0, title)
  normal dd
  :0
  setlocal nomodified
  setlocal nomodifiable
endfunction
"
"
"
function! s:bufnr()
  return bufexists(substitute(substitute(s:buf_name, '[', '\\[', 'g'), ']', '\\]', 'g') . '$')
endfunction
"
"
"
function! s:unescape(msg)
  let msg = a:msg
  let msg = substitute(msg, '&quot;', '"', 'g')
  let msg = substitute(msg, '&lt;'  , '<', 'g')
  let msg = substitute(msg, '&gt;'  , '>', 'g')
  return msg
endfunction
"
"
"
function! s:padding(msg, length)
  let msg = a:msg
  while len(msg) < a:length
    let msg = msg . ' '
  endwhile
  return msg
endfunction
"
"
"
function! s:separator(s)
  let sep = ""
  while len(sep) + 4 < winwidth(0)
    let sep .= a:s
  endwhile
  return sep
endfunction
"
"
"
augroup tweetvim
  autocmd!
  autocmd FileType tweetvim call s:tweetvim_settings()
augroup END  
"
"
"
function! s:tweetvim_settings()
  nmap <silent> <buffer> <CR> :call <SID>tweetvim_action_enter()<CR>
  nmap <silent> <buffer> <Leader>r :call <SID>tweetvim_action_reply()<CR>
endfunction
"
"
function! s:tweetvim_action_enter()
  let matched = matchlist(expand('<cWORD>') , 'https\?://\S\+')
  if len(matched) != 0
    execute "OpenBrowser " . matched[0]
    return
  endif
endfunction
"
"
"
function! s:tweetvim_action_reply()
  let tweet = b:tweetvim_status_cache[line('.')]
  let screen_name = tweet.screen_name
  let status_id   = tweet.id
  echo screen_name . ' ' . status_id
endfunction
