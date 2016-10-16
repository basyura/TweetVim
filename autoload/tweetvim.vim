call tweetvim#cache#read('screen_name')

let s:version = 2.4

let s:stream_cache = []

let s:last_receive_stream_time = reltime()

let s:notification_cache = []
let s:timer = 0
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
    redraw
    echohl Error | echo tweetvim#util#sudden_death("no tweet") | sleep 2 | redraw | echohl None
    return
  endif
  let req_time = reltimestr(reltime(st_req))
  " check error
  if type(tweets) == 4
    if has_key(tweets, 'error')
      echohl Error | echo tweets.error | echohl None
      return
    elseif has_key(tweets, 'errors')
      echohl Error | echo tweetvim#util#sudden_death(tweets.errors[0].message) | echohl None
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


function! tweetvim#userstream(bang, ...)
  let title = a:0 > 0 ? 'userstream track : ' . join(a:000, ',') : 'userstream'
  call tweetvim#buffer#userstream(title)

  let tweets = tweetvim#request('home_timeline', [])
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

  let b:tweetvim_userstream_bang  = a:bang
  let b:tweetvim_userstream_track = track
  " for rate limit
  if type(tweets) == 4
    if has_key(tweets, 'errors')
      echohl Error | echo tweetvim#util#sudden_death(tweets.errors[0].message) | echohl None
    endif
  else
    for tweet in tweetvim#filter#execute(reverse(tweets))
      call tweetvim#buffer#append(tweet)
    endfor
  endif

  normal! G

  let screen_name = tweetvim#account#current().screen_name
  execute 'syntax match tweetvim_reply "\zs.*@' . screen_name . '\_.\{-}\ze\s\[\["'

  let s:stream = s:twibill().stream('user', param)

  if s:timer != 0
    call timer_stop(s:timer)
  end
  let s:timer = timer_start(g:tweetvim_updatetime, function('s:receive_userstream'), {'repeat' : -1})
  augroup tweetvim-userstream
    autocmd!
    autocmd! BufDelete <buffer> call <SID>twibill().close_streams()
    autocmd! BufDelete <buffer> call <SID>close_stream()
  augroup END
endfunction

function! s:close_stream()
  call timer_stop(s:timer)
endfunction

function! s:receive_userstream(timer)

  if s:stream.stdout.eof
    if &filetype == 'tweetvim'
      echomsg "stream is already closed"
    endif
    return
  endif

  let res = substitute(s:stream.stdout.read_line(1000, 0), '', '', 'g')

  if substitute(res, '\n', '', 'g') != '' && res[0] == '{'
    call extend(s:stream_cache, s:to_tweets(res))
  endif


  if &filetype != 'tweetvim' || get(b:, 'tweetvim_method', '') != 'userstream'
    return
  endif

  for tweet in tweetvim#filter#execute(s:stream_cache)
    call s:cache_notify(tweet)
    call s:flush_tweet(tweet)
  endfor
  let s:last_receive_stream_time = reltime()
  call s:flush_notify()

  let s:stream_cache = []
  " auto reconnect
  if reltime(s:last_receive_stream_time)[0] >= g:tweetvim_reconnect_seconds
    " todo restore param
    let s:last_receive_stream_time = reltime()
    let s:stream = s:twibill().stream('user', {})
    echohl Error | echo 'reconnected to userstream' | echohl None
  endif

endfunction

function! s:log(tweet)
  :execute ":redir! >> /tmp/tweetvim.log"
      :execute ":silent! echon " . twibill#json#encode(a:tweet)
  :redir END
endfunction

function! s:flush_tweet(tweet)
  let tweet = a:tweet
  try
    if has_key(tweet, 'friends') || has_key(tweet, 'delete') || has_key(tweet, 'event') || has_key(tweet,'disconnect') || has_key(tweet, 'status_withheld') || has_key(tweet,'user_withheld')
      return
    endif
    let isbottom = line(".") == line("$")
    call tweetvim#buffer#append(tweet)
    if isbottom
      normal! G
    else
      if has_key(tweet,'text')
        execute "normal! " . string(len(split(tweet.text, '\r')) + 1) . "\<C-e>"
      elseif has_key(tweet,'direct_message')
        execute "normal! " . string(len(split(tweet.direct_message.text, '\r')) + 1) . "\<C-e>"
      endif
    endif
  catch
    setlocal modifiable
    "call append(line("$"), a:tweet)
    call append(line("$"), v:exception)
    setlocal nomodifiable
    normal! G
    "echo "decode error"
  endtry
endfunction
"
"
"
function! s:cache_notify(tweet)
  let tweet = a:tweet
  let current_screen_name = tweetvim#account#current().screen_name
  if has_key(tweet, 'event') && tweet.source.screen_name != current_screen_name
    if tweet.event == 'favorite'
      call add(s:notification_cache, {
            \ 'hook'        : 'notify_fav',
            \ 'from_user'   : tweet.source,
            \ 'status'      : tweet.target_object,
            \})
    endif
    if tweet.event == 'unfavorite'
      call add(s:notification_cache, {
            \ 'hook'        : 'notify_unfav',
            \ 'from_user'   : tweet.source,
            \ 'status'      : tweet.target_object,
            \})
    endif
  elseif has_key(tweet, 'retweeted_status')
    if tweet.retweeted_status.user.screen_name == current_screen_name
      call add(s:notification_cache, {
            \ 'hook'        : 'notify_retweet',
            \ 'from_user'   : tweet.user,
            \ 'status'      : tweet.retweeted_status,
            \})
    endif
  elseif has_key(tweet, 'status')
    if tweet.text =~ '@' . current_from
      call add(s:notification_cache, {
            \ 'hook'        : 'notify_mention',
            \ 'from_user'   : tweet.user,
            \ 'status'      : tweet,
            \})
    endif
  endif
endfunction
"
"
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
      let tweet = twibill#json#decode(eval("a:message[" . start . ":" . idx . "]"))
        call add(list, tweet)
      let start = idx + 1
    endif
    let idx += 1 
  endwhile

  return list
endfunction
"
"
"
function! s:flush_notify()
  if len(s:notification_cache) == 0
    return
  endif

  for notification in s:notification_cache
    if notification.hook == 'notify_fav'
      let status = deepcopy(notification.status)
      let status.text = ('by ' . notification.from_user.screen_name . "\n" . status.text)
      let status.favorited = 1
      call s:flush_tweet(status)
    endif
    call tweetvim#hook#fire(notification.hook, notification.from_user, notification.status)
  endfor

  let s:notification_cache = []

endfunction

