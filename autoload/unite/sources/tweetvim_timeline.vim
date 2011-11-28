
function! unite#sources#tweetvim_timeline#define()
  return s:source
endfunction

let s:source = {
      \ 'name': 'tweetvim',
      \ 'hooks' : {},
      \ 'action_table' : {},
      \ 'default_action' : {'common' : 'execute'},
      \ }

function! unite#sources#tweetvim_timeline#start()
  if !exists(':Unite')
    echoerr 'unite.vim is not installed.'
    echoerr 'Please install unite.vim'
    return ''
  endif

  return unite#start(['tweetvim'])
endfunction

function! s:source.gather_candidates(args, context)
  let list = []
  "TODO : list , and arguments
  for v in ['home_timeline', 'mentions']
    call add(list, {'word' : v , 'source__method' : v})
  endfor

  unlet v

  for v in tweetvim#lists()
    call add(list, {
          \ 'word' : v.full_name ,
          \ 'source__method' : 'list_statuses',
          \ 'source__args'   : [v.user.name, v.name],
          \ })
  endfor

  return list
endfunction

let s:source.action_table.execute = {'description' : 'show timeline'}
function! s:source.action_table.execute.func(candidate)
  let args = get(a:candidate, 'source__args', [])
  call tweetvim#timeline(a:candidate.source__method, args)
endfunction
