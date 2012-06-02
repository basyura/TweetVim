let s:consumer_key    = '8hht6fAi3wU47cwql0Cbkg'
let s:consumer_secret = 'sbmqcNqlfwpBPk8QYdjwlaj0PIZFlbEXvSxxNrJDcAU'
"
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
    "if type(args) == 3 && !empty(args) && type(args[-1]) == 4 && has_key(args[-1], 'opt')
      "let opt = args[-1].opt
      "call remove(args[-1], 'opt')
    "endif
  endif

  let st_req = reltime()
  let tweets = tweetvim#request(a:method, args)
  let req_time = reltimestr(reltime(st_req))

  if type(tweets) == 4 && has_key(tweets, 'error')
    echohl Error | echo tweets.error | echohl None
    return
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
function! tweetvim#access_token()
  
  let token_path = g:tweetvim_config_dir . '/token'
  if filereadable(token_path)
    return readfile(token_path)
  endif

  try
    let ctx = twibill#access_token({
                \ 'consumer_key'    : s:consumer_key,
                \ 'consumer_secret' : s:consumer_secret,
                \ })

    let tokens = [ctx.access_token, ctx.access_token_secret]

    call writefile(tokens , token_path)

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
function! tweetvim#verify_credentials()
  if !exists('s:credencidals')
    let credencidals = tweetvim#request('verify_credentials', [])
    if has_key(credencidals, 'error')
      echohl Error | echo credencidals.error | echohl None
      return {'screen_name' : ''}
    endif
    let s:credencidals = credencidals
  endif
  return copy(s:credencidals)
endfunction
"
"
"
function! tweetvim#lists()
  if !exists('s:cache_lists')
    let info = tweetvim#verify_credentials()
    if empty(info)
      return []
    endif
    let s:cache_lists = tweetvim#request('lists', [info.screen_name]).lists
  endif
  return copy(s:cache_lists)
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
  return join(keys(tweetvim#cache#get('screen_name'), "\n")
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
