call tweetvim#cache#read('screen_name')

let s:version = 1.9
"
"
function! tweetvim#version()
  return s:version
endfunction
"
"
function! tweetvim#timeline(method, ...)
  let start = reltime()
  " TODO - for list_statuses at tweetvim/timeline action
  let args = (a:0 == 1 && type(a:1) == 3) ? a:1 : a:000
  " TODO - to add some information
  let opt  = {}
  if a:method == 'user_timeline'
    let opt.user_detail = 1
  endif

  let st_req = reltime()
  let tweets = tweetvim#request(a:method, args)
  if empty(tweets)
    return
  endif
  let req_time = reltimestr(reltime(st_req))
  " check error
  if type(tweets) == 4
    if has_key(tweets, 'error')
      echohl Error | echo tweets.error | echohl None
      return
    elseif has_key(tweets, 'errors')
      echohl Error | echo s:sudden_death(tweets.errors[0].message) | echohl None
      return
    endif
  endif

  " TODO:
  " delete cache for previous and next
  " buf no is -1 -2 -3 ... oldest
  let bufno = get(b:, 'tweetvim_bufno', 0)
  if bufno < -1
    call tweetvim#buffer#truncate_backup(bufno)
  endif

  let st_load = reltime()
  call tweetvim#buffer#load(
        \ a:method,
        \ a:000,
        \ join(split(a:method, '_'), ' '), 
        \ tweets,
        \ opt)

  let load_time = reltimestr(reltime(st_load))

  try 
    call tweetvim#cache#write('screen_name', map(copy(tweets), 'v:val.user.screen_name'))
  catch
    " noop
  endtry

  if get(g:, 'tweetvim_debug', 0)
    let time = 'total:' . reltimestr(reltime(start)) . ' req:' . req_time . ' load:' . load_time
    call tweetvim#buffer#replace(1, getline('.') . '   (' . time . ')')
  endif
endfunction
"
"
"
function! tweetvim#request(method, args)
  let args  = type(a:args) == 3 ? a:args : [a:args]
  let param = {'per_page' : g:tweetvim_tweet_per_page,
              \'count'    : g:tweetvim_tweet_per_page,
              \'include_entities' : 1}
  let param.include_rts = get(g:, 'tweetvim_include_rts', 1)
  let args  = s:merge_params(args, param)

  try
    let twibill = s:twibill()
  catch /AccessTokenError/
    "echoerr 'You must install twibill.vim (https://github.com/basyura/twibill.vim)'
    return []
  endtry

  return call(twibill[a:method], args, twibill)
endfunction


function! tweetvim#userstream(...)
  let title = a:0 > 0 ? 'userstream track : ' . join(a:000, ',') : 'userstream'
  call tweetvim#buffer#userstream(title)

  let tweets = tweetvim#request('home_timeline', [])
  " for rate limit
  if type(tweets) == 4
    if has_key(tweets, 'errors')
      echohl Error | echo s:sudden_death(tweets.errors[0].message) | echohl None
    endif
  else
    for tweet in reverse(tweets)
      call tweetvim#buffer#append(tweet)
    endfor
  endif

  normal! G
  " create param
  let param = {}
  let track = []
  for value in a:000
    if value =~ '^lang:'
      let param.language = split(value, 'lang:')[0]
    elseif value =~ '^language:'
      let param.language = split(value, 'language:')[0]
    else
      call add(track, value)
    endif
  endfor
  if len(track) > 0
    let param.track = join(track, ',')
  endif

  let s:stream = s:twibill().stream('user', param)
  if !exists('b:saved_tweetvim_updatetime')
    let b:saved_tweetvim_updatetime = &updatetime
  endif
  let &updatetime = g:tweetvim_updatetime
  augroup tweetvim-userstream
    autocmd!
    autocmd! CursorHold,CursorHoldI * call s:receive_userstream()
    autocmd! BufEnter <buffer> execute "let &updatetime=" . g:tweetvim_updatetime
    autocmd! BufLeave <buffer> execute "let &updatetime=" . b:saved_tweetvim_updatetime
  augroup END
endfunction


function! s:receive_userstream()
  if s:stream.stdout.eof
    echomsg "stream is already closed"
    return
  endif

  if &filetype != 'tweetvim' || get(b:, 'tweetvim_method', '') != 'userstream'
    return
  endif

  let res = substitute(s:stream.stdout.read_line(), '', '', 'g')

  if substitute(res, '\n', '', 'g') != '' && res[0] == '{'
    for tweet in s:to_tweets(res)
      try
        if has_key(tweet, 'friends') || has_key(tweet, 'delete') || has_key(tweet, 'event')
          continue
        endif
        let isbottom = line(".") == line("$")
        call tweetvim#buffer#append(tweet)
        if isbottom
          normal! G
        else
          execute "normal! " . string(len(split(tweet.text, '\r')) + 1) . "\<C-e>"
        endif
      catch
        setlocal modifiable
        call append(line("$"), res)
        call append(line("$"), v:exception)
        setlocal nomodifiable
        normal! G
        "echo "decode error"
      endtry
    endfor
  endif
  let &updatetime = g:tweetvim_updatetime
  call feedkeys("g\<Esc>", "n")
endfunction



"
function! tweetvim#update(text, param)
  return tweetvim#request('update', [a:text, a:param])
endfunction
"
"
"
function! tweetvim#action(name)
  let tweet = get(b:tweetvim_status_cache, line('.'), {})
  let def   = function('tweetvim#action#' . a:name . '#define')()
  " TODO: check executable
  if get(def, 'need_tweet', 1) && empty(tweet)
    echo 'no action'
    return
  endif

  let Fn = function('tweetvim#action#' . a:name . '#execute')
  call Fn(tweet)
endfunction
"
"
"
function! s:twibill()
  if twibill#version() < 1.1
    throw "you must udpate to twibill 1.1"
  endif
  " check current user
  if exists('s:twibill')
    if tweetvim#account#current().screen_name == s:twibill.screen_name
      return s:twibill
    endif
    call s:twibill.close_streams()
  endif

  let config = tweetvim#account#access_token()
  let config.cache   = 1
  let config.isAsync = g:tweetvim_async_post

  let s:twibill      = tweetvim#twibill#new(config)
  let s:twibill.screen_name = tweetvim#account#current().screen_name
  return s:twibill
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
"
" from suddendeath.vim - MIT License
"
function! s:sudden_death(str)
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
"
"
function! s:to_tweets(message)
  let counter = 0
  let start   = 0
  let idx     = 0
  let list    = []
  while idx < len(a:message)
    let s = a:message[idx]
    if s == '{'
      let counter += 1
    elseif s == '}'
      let counter -= 1
    endif
    if counter == 0
      let tweet = webapi#json#decode(eval("a:message[" . start . ":" . idx . "]"))
        call add(list, tweet)
      let start = idx + 1
    endif
    let idx += 1 
  endwhile

  return list
endfunction
