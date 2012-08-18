
function! unite#sources#tweetvim_switch_account#define()
  return s:source
endfunction

let s:source = {
      \ 'name': 'tweetvim/account',
      \ 'action_table'   : {},
      \ 'default_action' : {'common' : 'execute'},
      \ }

function! unite#sources#tweetvim_switch_account#start()
  if !exists(':Unite')
    echoerr 'unite.vim is not installed.'
    echoerr 'Please install unite.vim'
    return ''
  endif

  return unite#start(['tweetvim/account'])
endfunction

function! s:source.gather_candidates(args, context)
  let candidates = []
  for account in tweetvim#account_list()
    call add(candidates, {
          \ 'word' : account,
          \ 'abbr' : (tweetvim#current_account() == account ? '* ' : '  ') . account ,
          \ })
  endfor
  return candidates
endfunction

let s:source.action_table.execute = {'description' : 'add to list'}
function! s:source.action_table.execute.func(candidate)
  call tweetvim#switch_account(a:candidate.word)
endfunction

 
