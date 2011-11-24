let s:consumer_key    = '8hht6fAi3wU47cwql0Cbkg'
let s:consumer_secret = 'sbmqcNqlfwpBPk8QYdjwlaj0PIZFlbEXvSxxNrJDcAU'

let s:config_path = expand('~/.tweetvim')

let s:buf_name = '[tweetvim]'
"
"
"
function! tweetvim#timeline(method, ...)
  let start = reltime()

  let tweets = tweetvim#request(a:method, a:000)

  if type(tweets) == 4 && has_key(tweets, 'error')
    echohl Error | echo tweets.error | echohl None
    return
  endif

  call tweetvim#load_timeline(
        \ a:method,
        \ a:000,
        \ join(split(a:method, '_'), ' '), 
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
function! tweetvim#request(method, args)

  let param = {'per_page' : 50, 'count' : 50}

  let args = s:merge_params(a:args, param)

  let twibill = s:twibill()
  let Fn      = twibill[a:method]

  return call(Fn, args, twibill)
endfunction
"
"
"
function! tweetvim#load_timeline(method, args, title, tweets, ...)
  let param = a:0 ? a:1 : {}
  let buf_name = get(param, 'buf_name', s:buf_name)

  let start = reltime()
  let bufno = s:bufnr(buf_name)
  if bufno > 0
    execute 'buffer ' . bufno
  else
    " TODO
    if get(param, 'split', 0)
      split
    endif
    execute 'edit! ' . buf_name
  endif

  setlocal noswapfile
  setlocal modifiable
  setlocal buftype=nofile
  setfiletype tweetvim

  silent %delete _

  let b:tweetvim_method = a:method
  let b:tweetvim_args   = a:args
  let b:tweetvim_status_cache = {}

  call s:append_tweets(a:tweets, b:tweetvim_status_cache)

  let title  = '[tweetvim]  - ' . a:title
  call append(0, title)
  normal dd
  :0

  if get(param, 'split', 0)
    execute string(len(a:tweets) * 2 + 2) . 'wincmd _'
  endif

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
function! s:append_tweets(tweets, cache)
  let separator = tweetvim#util#separator('-')
  let is_new    = 1
  for tweet in a:tweets
    " add new or default separator
    if is_new && !has_key(tweet, 'is_new')
      call append(line('$') - 1, tweetvim#util#separator(' '))
      let is_new = 0
    else
      call append(line('$') - 1, separator)
    endif

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
    " cache tweet by line no
    let a:cache[line(".")] = tweet
  endfor

endfunction
"
"
"
function! s:bufnr(buf_name)
  return bufexists(substitute(substitute(a:buf_name, '[', '\\[', 'g'), ']', '\\]', 'g') . '$')
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
    call extend(param[-1], a:hash_param)
    return param
  endif

  return param + [a:hash_param]
endfunction



