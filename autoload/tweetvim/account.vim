let s:consumer_key    = '8hht6fAi3wU47cwql0Cbkg'
let s:consumer_secret = 'sbmqcNqlfwpBPk8QYdjwlaj0PIZFlbEXvSxxNrJDcAU'

let s:current  = ''
let s:accounts = {}

function! tweetvim#account#access_token()

  let param = a:0 ? a:1 : {}
  " find registed account
  if get(param, 'mode', '') == ''
    " find account's token
    let token_path = s:token_path()
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




function! tweetvim#account#current()
  if s:current == ''
    if g:tweetvim_default_account != ''
      let s:current = g:tweetvim_default_account
    else
      let accounts = tweetvim#account#users()
      if len(accounts) != 0
        let s:current = accounts[0]
      endif
    endif
  endif
  return s:current
endfunction


"function! s:manager.switch(screen_name)
  "if index(self.accounts(), a:screen_name) < 0
    "return 0
  "endif
  "let self.c_current = a:screen_name
  "return 1
"endfunction

"function! s:manager.add(account)
  "let self.c_accounts[a:account.screen_name] = a:account
  "let self.c_current = a:account.screen_name
"endfunction

"function! s:manager.verify_credentials()
  "if empty(self.c_accounts[self.c_current].verify_credentials)
    "let credencials = tweetvim#request('verify_credentials', [])
    "if has_key(credencials, 'error')
      "echohl Error | echo credencials.error | echohl None
      "return {'screen_name' : ''}
    "endif
    "let self.c_accounts[self.c_current].verify_credentials = credencials
  "endif
  "return deepcopy(self.c_accounts[self.c_current].verify_credentials)
"endfunction

function! tweetvim#account#lists()
  if !has_key(s:accounts[s:current], 'lists')
    let lists = tweetvim#request('lists', [s:current]).lists
    let s:accounts[s:current]['lists'] = lists
  endif
  return copy(s:accounts[s:current].lists)
endfunction

function! tweetvim#account#users()
  return keys(s:accounts)
endfunction

function! tweetvim#account#new_manager()
  let manager = deepcopy(s:manager)

  for account in s:account_list()
    let manager.c_accounts[account] = {}
    let manager.c_accounts[account]['verify_credentials'] = {}
  endfor

  return manager
endfunction

function! s:account_list()
  return map(filter(split(globpath(g:tweetvim_config_dir . '/accounts', "*"), "\n"), "isdirectory(v:val)"), "fnamemodify(v:val, ':t:r')")
endfunction

function! s:token_path()
  return g:tweetvim_config_dir . '/accounts/' . tweetvim#account#current() . '/token'
endfunction
