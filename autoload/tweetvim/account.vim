
let s:manager = {
      \ 'c_current'  : '',
      \ 'c_accounts' : {},
      \ }

function! s:manager.current()
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

function! s:manager.switch(screen_name)
  if index(self.accounts(), a:screen_name) < 0
    return 0
  endif
  let self.c_current = a:screen_name
  return 1
endfunction

function! s:manager.add(account)
  let self.c_accounts[account.screen_name] = account
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

