
let s:buf_name = '[tweetvim]'
"
"
"
function! tweetvim#buffer#load(method, args, title, tweets, ...)
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

    call append(line('$') - 1, s:format(tweet))
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
function! s:format(tweet)
  let text = a:tweet.text
  let text = substitute(text , '
  let text = substitute(text , '\n' , '' , 'g')
  let text = tweetvim#util#unescape(text)

  let str  = tweetvim#util#padding(a:tweet.user.screen_name, 15) . ' : '
  if a:tweet.favorited
    let str .= '★ '
  endif
  let str .= text

  return str
endfunction