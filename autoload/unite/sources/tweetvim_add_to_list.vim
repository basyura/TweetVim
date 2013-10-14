
function! unite#sources#tweetvim_add_to_list#define()
  return s:source
endfunction

let s:source = {
      \ 'name': 'tweetvim/add_to_list',
      \ 'action_table'   : {},
      \ 'default_action' : {'common' : 'execute'},
      \ 'is_listed'      : 0,
      \ }

function! s:source.gather_candidates(args, context)
  return map(tweetvim#account#current().get_lists() , '{
             \ "word" : v:val.slug,
             \ "source__screen_name" : a:args[0],
             \ }')

endfunction

let s:source.action_table.execute = {'description' : 'add to list'}
function! s:source.action_table.execute.func(candidate)
  let name = a:candidate.word
  let msg  = 'add ' . a:candidate.source__screen_name .  ' to ' . name  . ' ? [y/n] : '
  if input(msg) != 'y'
    return
  endif
  let user = tweetvim#account#current().screen_name
  call tweetvim#request("add_member_to_list", 
        \ [name, a:candidate.source__screen_name, user])
  redraw
  echo 'added'
endfunction
