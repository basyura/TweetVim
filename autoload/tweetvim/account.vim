
let s:manager = {
      \ 'c_current'  : '',
      \ 'c_accounts' : {},
      \ }

function! s:manager.current(...)
  " set current screen_name
  if a:0
    let self.c_current = a:1
    if a:0 > 2
      self.c_accounts[a:1].verify_credentials = a:2
    endif
    return a:1
  endif

  if self.c_current == ''
    if g:tweetvim_default_account != ''
      let self.c_current = g:tweetvim_default_account
    else
      let accounts = self.accounts()
      if len(accounts) != 0
        let self.c_current = accounts[0]
      endif
    endif
  endif
  return self.c_current
endfunction

function! s:manager.verify_credentials()
  if empty(self.c_accounts[self.c_current].verify_credentials)
    let credencials = tweetvim#request('verify_credentials', [])
    if has_key(credencials, 'error')
      echohl Error | echo credencials.error | echohl None
      return {'screen_name' : ''}
    endif
    let self.c_accounts[self.c_current].verify_credentials = credencials
  endif
  return deepcopy(self.c_accounts[self.c_current].verify_credentials)
endfunction

function! s:manager.lists()
  if !has_key(self.c_accounts[self.c_current], 'lists')
    let lists = tweetvim#request('lists', [self.c_current]).lists
    let self.c_accounts[self.c_current]['lists'] = lists
  endif
  return copy(self.c_accounts[self.c_current].lists)
endfunction

function! s:manager.accounts()
  return keys(self.c_accounts)
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

