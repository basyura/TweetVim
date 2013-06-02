
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
  let current    = tweetvim#account#current().screen_name
  for user in tweetvim#account#users()
    call add(candidates, {
          \ 'word' : user.screen_name,
          \ 'abbr' : (current == user.screen_name ? '* ' : '  ') . user.screen_name ,
          \ })
  endfor
  call sort(candidates, 's:sort_by_screen_name')
  return candidates
endfunction

let s:source.action_table.execute = {'description' : 'add to list'}
function! s:source.action_table.execute.func(candidate)
  call tweetvim#account#current(a:candidate.word)
  call tweetvim#timeline("home_timeline")
endfunction

function! s:sort_by_screen_name(i1, i2)
  return a:i1.word == a:i2.word ? 0 : a:i1.word > a:i2.word ? 1 : -1
endfunction 
