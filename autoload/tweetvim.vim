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
  let param = {'in_reply_to_status_id' : tweet.id_str}
  call tweetvim#say#open('@' . tweet.user.screen_name . ' ', param)
endfunction
"
"
"
function! tweetvim#update(text, param)
    return s:twibill().update(a:text, a:param)
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



