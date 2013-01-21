let s:consumer_key    = '8hht6fAi3wU47cwql0Cbkg'
let s:consumer_secret = 'sbmqcNqlfwpBPk8QYdjwlaj0PIZFlbEXvSxxNrJDcAU'

let s:current  = ''
" let s:user = {'screen_name' : '' , 'lists' : []}
let s:accounts = {}




function! tweetvim#account#access_token(...)

  let param = a:0 ? a:1 : {}
  " find registed account
  if get(param, 'mode', '') == ''
    " find account's token
    let token_path = s:token_path(s:current)
    if filereadable(token_path)
      let tokens = readfile(token_path)
      return {
        \ 'consumer_key'        : s:consumer_key ,
        \ 'consumer_secret'     : s:consumer_secret ,
        \ 'access_token'        : tokens[0] ,
        \ 'access_token_secret' : tokens[1] ,
        \ }
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

    let folder = g:tweetvim_config_dir . '/accounts/' . account.screen_name
    if !isdirectory(folder)
      call mkdir(folder, 'p')
    endif

    let token_path = g:tweetvim_config_dir . '/accounts/' . account.screen_name . '/token'
    call writefile(tokens , token_path)

    let s:accounts[account.screen_name] = account

    let s:current = account.screen_name

    return config
  catch
    redraw
    echohl Error | echo "failed to get access token" | echohl None
    if g:tweetvim_debug | echoerr v:exception | endif
    throw "AccessTokenError"
  endtry
endfunction

function! tweetvim#account#current(...)
  let current = s:current
  " TODO: refactoring
  if a:0 > 0
    if index(map(tweetvim#account#users(), 'v:val.screen_name'), a:1) < 0
      echohl Error | echo 'failed to switch ' . a:1 | echohl None
      return {}
    endif
    let current = a:1
    echohl Keyword | echo 'current account is ' . current | echohl None
  else
    if current == ''
      " for get first account & display timeline
      if g:tweetvim_default_account != ''
        let current = g:tweetvim_default_account
      else
        let users   = tweetvim#account#users()
        if !empty(users)
          let current = users[0].screen_name
        endif
      endif
    endif
  endif


  let s:current = current
  if s:current == ''
    if g:tweetvim_debug | echoerr "current account is empty" | endif
    throw "AccessTokenError"
  endif
  let account   = s:accounts[s:current]
  try 
    if !has_key(account, 'lists')
      let account.lists = tweetvim#request('lists', s:current)
    endif
  catch
      let account.lists = []
  endtry

  return deepcopy(account)
endfunction

function! tweetvim#account#add()
  try
    call tweetvim#account#access_token({'mode' : 'new'})
  catch /AccessTokenError/
    return
  endtry
  :TweetVimHomeTimeline
  redraw
  echohl Keyword | echo 'added account' |  echohl None
endfunction

function! tweetvim#account#users()
  return deepcopy(sort(values(s:accounts)))
endfunction

function! s:token_path(screen_name)
  return g:tweetvim_config_dir . '/accounts/' . a:screen_name . '/token'
endfunction

function! s:load_accounts()
  let list = s:account_list()
  for account in list
    let s:accounts[account] = {
      \ 'screen_name' : account,
      \ }
  endfor
  if g:tweetvim_default_account != ''
    let s:current = g:tweetvim_default_account
  elseif len(list) != 0
    let s:current = list[0]
  endif
endfunction

function! s:account_list()
  return map(filter(split(globpath(g:tweetvim_config_dir . '/accounts', "*"), "\n"), "isdirectory(v:val)"), "fnamemodify(v:val, ':t:r')")
endfunction

call s:load_accounts()
