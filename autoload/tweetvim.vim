let s:consumer_key    = '8hht6fAi3wU47cwql0Cbkg'
let s:consumer_secret = 'sbmqcNqlfwpBPk8QYdjwlaj0PIZFlbEXvSxxNrJDcAU'
"
" TODO : account manager
let s:acMgr = tweetvim#account#new_manager()
"
"
let s:hooks = {
      \ 'write_screen_name' : [],
      \ 'write_hash_tag'    : [],
      \ }
" for screen_name complete
call tweetvim#cache#read('screen_name')
"
"
function! tweetvim#timeline(method, ...)
  call s:log('tweetvim#timeline ' . a:method . ' start')
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
  let req_time = reltimestr(reltime(st_req))
  " check error
  if type(tweets) == 4
    if has_key(tweets, 'error')
      echohl Error | echo tweets.error | echohl None
      return
    elseif has_key(tweets, 'errors')
      echohl Error | echo tweets.errors[0].message | echohl None
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

  call tweetvim#cache#write('screen_name', map(copy(tweets), 'v:val.user.screen_name'))

  if get(g:, 'tweetvim_debug', 0)
    let time = 'total:' . reltimestr(reltime(start)) . ' req:' . req_time . ' load:' . load_time
    call tweetvim#buffer#replace(1, getline('.') . '   (' . time . ')')
  endif

  call s:log('tweetvim#timeline ' . a:method . ' end')
endfunction
"
"
"
function! tweetvim#switch_account(screen_name)
  if s:acMgr.switch(a:screen_name)
    echohl Keyword | echo 'current account is ' . s:acMgr.current() | echohl None
  else
    echohl Error | echo 'failed to switch ' . a:screen_name | echohl None
  endif
endfunction
"
"
function! tweetvim#add_account()
  let token = tweetvim#access_token({'mode' : 'new'})
  " check error
  if token[0] == 'error'
    return
  endif
  redraw
  echohl Keyword | echo 'added account - ' . s:acMgr.current() | echohl None
endfunction
"
"
function! tweetvim#access_token(...)
  let param = a:0 ? a:1 : {}
  " find registed account
  if get(param, 'mode', '') == ''
    " find account's token
    let token_path = g:tweetvim_config_dir . '/accounts/' . s:acMgr.current() . '/token'
    if filereadable(token_path)
      return readfile(token_path)
    endif
  endif

  try
    let ctx = twibill#access_token({
                \ 'consumer_key'    : s:consumer_key,
                \ 'consumer_secret' : s:consumer_secret,
                \ })

    let tokens = [ctx.access_token, ctx.access_token_secret]

    let config = {
      \ 'consumer_key'        : s:consumer_key ,
      \ 'consumer_secret'     : s:consumer_secret ,
      \ 'access_token'        : tokens[0] ,
      \ 'access_token_secret' : tokens[1] ,
      \ }

    let account    = twibill#new(config).verify_credentials()
    let token_path = g:tweetvim_config_dir . '/accounts/' . account.screen_name . '/token'

    call mkdir(g:tweetvim_config_dir . '/accounts/' . account.screen_name, 'p')
    call writefile(tokens , token_path)

    call s:acMgr.add(account)

    return tokens
  catch
    redraw
    echohl Error | echo "failed to get access token" | echohl None
    return ['error','error']
  endtry
endfunction
"
"
"
function! tweetvim#current_account()
  return s:acMgr.current()
endfunction
"
"
"
function! tweetvim#request(method, args)
  let args  = type(a:args) == 3 ? a:args : [a:args]
  let param = {'per_page' : g:tweetvim_tweet_per_page, 
              \'count'    : g:tweetvim_tweet_per_page}
  let param.include_rts = get(g:, 'tweetvim_include_rts', 1)
  let args  = s:merge_params(args, param)

  try
    let twibill = s:twibill()
  catch
    echoerr 'You must install twibill.vim (https://github.com/basyura/twibill.vim)'
    return {}
  endtry

  return call(twibill[a:method], args, twibill)
endfunction

"
function! tweetvim#update(text, param)
  return tweetvim#request('update', [a:text, a:param])
endfunction
"
"
"
function! tweetvim#action(name)
  let tweet = tweetvim#buffer#get_status_cache(line('.'))
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
function! tweetvim#lists()
  return s:acMgr.lists()
endfunction
"
"
"
"
function! tweetvim#accounts()
  return s:acMgr.accounts()
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
  "if exists('s:twibill_cache')
  "  return s:twibill_cache
  "endif
  "let s:twibill_cache = tweetvim#twibill#new(s:config())
  "return s:twibill_cache
  return tweetvim#twibill#new(s:config())
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
function! tweetvim#complete_screen_name(argLead, cmdLine, cursorPos)
  return join(tweetvim#cache#get('screen_name'), "\n")
endfunction
"
"
"
function! tweetvim#complete_account(arglead, ...)
  return join(s:acMgr.accounts(), "\n")
endfunction
"
"
"
function! tweetvim#complete_search(argLead, cmdLine, cursorPos)
  let name = tweetvim#cache#get('screen_name')
  let tag  = tweetvim#cache#get('hash_tag')
  call extend(name, tag)
  return join(name, "\n")
endfunction
"
"
"
function! tweetvim#complete_list(argLead, cmdLine, cursorPos)
  return join(map(tweetvim#lists(), 'v:val.name'), "\n")
endfunction
"
"
"
function! tweetvim#add_hook(name, func_name)
  if !has_key(s:hooks, a:name)
    echoerr 'tweetvim error no hook : ' . a:name
    return
  endif
  call add(s:hooks[a:name], a:func_name)
endfunction
"
"
"
function! tweetvim#fire_hooks(name, ...)
  if !has_key(s:hooks, a:name)
    echoerr 'tweetvim error no hook : ' . a:name
    return
  endif
  for func_name in s:hooks[a:name]
    call call(func_name, a:000)
  endfor
endfunction
"
"
"
function! tweetvim#log(msg, ...)
  " TODO
  if a:0
    call tweetvim#logger#log(a:msg, a:1)
  else
    call tweetvim#logger#log(a:msg)
  endif
endfunction
"
" alias for tweetvim#log
"
function! s:log(msg, ...)
  if a:0
    call tweetvim#logger#log(a:msg, a:1)
  else
    call tweetvim#logger#log(a:msg)
  endif
endfunction
"
"
"
function! tweetvim#__migration__()

  let from    = g:tweetvim_config_dir . '/token'
  let tokens  = readfile(from)
  let twibill = twibill#new({
    \ 'consumer_key'        : s:consumer_key ,
    \ 'consumer_secret'     : s:consumer_secret ,
    \ 'access_token'        : tokens[0] ,
    \ 'access_token_secret' : tokens[1] ,
    \ })

  let credentials = twibill.verify_credentials()
  let to_dir = g:tweetvim_config_dir . '/accounts/' . credentials.screen_name

  call mkdir(to_dir, 'p')
  call rename(from, to_dir . '/token')

  call s:acMgr.add(credentials)

  echomsg 'tweetvim - migrated token file'
endfunction
