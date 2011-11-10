let s:consumer_key    = '8hht6fAi3wU47cwql0Cbkg'
let s:consumer_secret = 'sbmqcNqlfwpBPk8QYdjwlaj0PIZFlbEXvSxxNrJDcAU'

let s:config_path = expand('~/.tweetvim')

let s:buf_name = '[tweetvim]'
"
"
"
function! tweetvim#timeline(method, ...)
  let start = reltime()

  let tweets = s:get_tweets(a:method, a:000)

  if type(tweets) == 4 && has_key(tweets, 'error')
    echohl Error | echo tweets.error | echohl None
    return
  endif

  call s:load_timeline(
        \ a:method,
        \ a:000,
        \ join(split(a:method, '_'), ' ') . ' (' . split(reltimestr(reltime(start)))[0] . ' [s])', 
        \ tweets)
endfunction
"
"
"
function! tweetvim#access_token()

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
function! tweetvim#reload()
  let ret = call('tweetvim#timeline', [b:tweetvim_method] + b:tweetvim_args)
endfunction
"
"
function! tweetvim#action_enter()
  let matched = matchlist(expand('<cWORD>') , 'https\?://[0-9A-Za-z_#?~=\-+%\.\/:]\+')
  if len(matched) != 0
    execute "OpenBrowser " . matched[0]
    return
  endif
endfunction
"
"
"
function! tweetvim#action_reply()
  let tweet = b:tweetvim_status_cache[line('.')]
  let screen_name = tweet.user.screen_name
  let status_id   = tweet.id
  echo screen_name . ' ' . status_id . ' ' . tweet.text
endfunction
"
"
"
function! tweetvim#update()
  let bufnr = bufwinnr('tweetvim-say')
  if bufnr > 0
    exec bufnr.'wincmd w'
  else
    execute 'below split unite_twitter' 
    execute '2 wincmd _'
  endif
  setlocal modifiable
  silent %delete _
  let &filetype = 'tweetvim-say'
  startinsert!
endfunction

function! s:post_tweet()
  let text  = join(getline(1, "$"))
  if strchars(text) > 140
    "call unite#util#print_error("over 140 chars")
    echohl Error | echo "over 140 chars" | echohl None
    return
  endif
  redraw | echo 'sending ... ' | sleep 1
  try
    let param = exists("b:post_param") ? b:post_param : {}
    "call rubytter#request('update' , text , param)
    call s:twibill().update(text, param)
  catch
    echoerr v:exception
    return
  endtry
  bd!
  redraw | echo 'sending ... ok'
endfunction
"
"
"
function! s:get_tweets(method, args)

  let param = {'per_page' : 50, 'count' : 50}

  let args = s:merge_params(a:args, param)

  let twibill = s:twibill()
  let Fn      = twibill[a:method]
  
  return call(Fn, args, twibill)
endfunction
"
"
"
function! s:load_timeline(method, args, title, tweets)
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
  let b:tweetvim_args   = a:args
  let b:tweetvim_status_cache = {}

  let separator = tweetvim#util#separator('-')

  call s:append_tweets(a:tweets[0], separator, b:tweetvim_status_cache)
  normal dd 
  call append(line('$') - 1, tweetvim#util#separator(' '))
  call s:append_tweets(a:tweets[1], separator, b:tweetvim_status_cache)

  let title  = '[tweetvim]  - ' . a:title
  let title .= ' (' . split(reltimestr(reltime(start)))[0] . ' [s])'
  let title .= ' : bufno ' . bufno

  call append(0, title)
  call append(1, separator)
  normal dd
  :0
  setlocal nomodified
  setlocal nomodifiable
endfunction
"
"
"
function! s:config()
  let tokens = tweetvim#access_token()
  return {
    \ 'consumer_key'        : s:consumer_key ,
    \ 'consumer_secret'     : s:consumer_secret ,
    \ 'access_token'        : tokens[0] ,
    \ 'access_token_secret' : tokens[1] ,
    \ 'cache'               : 1
    \ }
endfunction
"
"
"
function! s:twibill()
  if exists('s:twibill_cache')
    return s:twibill_cache
  endif
  let s:twibill_cache = tweetvim#twibill#new(s:config())
  return s:twibill_cache
endfunction
"
"
"
function! s:append_tweets(tweets, separator, cache)
  for tweet in a:tweets
    let text = tweet.text
    let text = substitute(text , '' , '' , 'g')
    let text = substitute(text , '\n' , '' , 'g')
    let text = tweetvim#util#unescape(text)

    let str  = tweetvim#util#padding(tweet.user.screen_name, 15) . ' : '
    if tweet.favorited
      let str .= '★ '
    endif
    let str .= text
    "let str .= ' - ' . status.find('created_at').value()
    "let str .= ' [' . status.find('id').value() . ']'
    call append(line('$') - 1, str)
    call append(line('$') - 1, a:separator)
    let a:cache[line(".")] = tweet
  endfor
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
function! s:merge_params(list_param, hash_param)
  if empty(a:list_param)
    return [a:hash_param]
  endif

  let param = a:list_param

  if type(param[-1]) == 4
    return extend(param[-1], a:hash_param)
  endif

  return param + [a:hash_param]
endfunction



"
"
"
augroup tweetvim-say
  autocmd! tweetvim-say
  autocmd FileType    tweetvim-say call s:tweetvim_say_settings()
  autocmd BufWinLeave tweetvim-say call s:tweetvim_say_leave()
augroup END


function! s:tweetvim_say_settings()
  setlocal bufhidden=wipe
  setlocal nobuflisted
  setlocal noswapfile
  setlocal modifiable
  setlocal nomodified
  nnoremap <buffer> <silent> q :bd!<CR>
  nnoremap <buffer> <silent> <C-s>      :call <SID>show_history()<CR>0
  inoremap <buffer> <silent> <C-s> <ESC>:call <SID>show_history()<CR>0
  nnoremap <buffer> <silent> <CR>       :call <SID>post_tweet()<CR>
  
  :0
  startinsert!
  " i want to judge by buffer variable
  if !exists('s:tweetvim_bufwrite_cmd')
    autocmd BufWriteCmd <buffer> echo 'please enter to tweet'
    let s:tweetvim_bufwrite_cmd = 1
  endif
endfunction

" for recovery tweet
let s:history = []

function! s:show_history()
  let no = len(s:history)
  if(no == 0)
    return
  endif
  let no = (exists('b:history_no') ? b:history_no : no) - 1
  if no == -1
    let no = len(s:history) - 1
  endif
  silent %delete _
  silent execute 'normal i' . s:history[no]
  let b:history_no = no
endfunction

function! s:save_history_at_leave()
  if &modifiable != 1
    return
  endif
  let msg = join(getline(1, "$"))
  if msg !~ '^\s\?$' && (len(s:history) == 0 || s:history[-1] != msg)
    call add(s:history , msg)
  endif
endfunction
