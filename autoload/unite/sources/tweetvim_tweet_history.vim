
function! unite#sources#tweetvim_tweet_history#define()
  return s:source
endfunction

let s:source = {
      \ 'name': 'tweetvim/tweet_history',
      \ 'action_table'   : {},
      \ 'default_action' : {'common' : 'execute'},
      \ 'is_listed'      : 0,
      \ }

function! unite#sources#tweetvim_tweet_history#start()
  if !exists(':Unite')
    echoerr 'unite.vim is not installed.'
    echoerr 'Please install unite.vim'
    return ''
  endif
  return unite#start(['tweetvim/tweet_history'])
endfunction

function! s:source.gather_candidates(args, context)
  return map(tweetvim#say#history() , '{
             \ "word" : v:val
             \ }')

endfunction

let s:source.action_table.execute = {'description' : 'tweet history'}
function! s:source.action_table.execute.func(candidate)
  silent %delete _
  call setline(1,a:candidate.word)
endfunction
