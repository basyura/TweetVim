
function! unite#sources#tweetvim#define()
  return s:source
endfunction

let s:source = {
      \ 'name': 'tweetvim',
      \ 'hooks' : {},
      \ 'action_table' : {},
      \ 'default_action' : {'common' : 'execute'},
      \ 'is_listed' : 0,
      \ }

function! unite#sources#tweetvim#start()
  if !exists(':Unite')
    echoerr 'unite.vim is not installed.'
    echoerr 'Please install unite.vim'
    return ''
  endif


  let tweet = get(b:tweetvim_status_cache, line('.'), {})
  if empty(tweet)
    echo "no cache"
    return ''
  endif

  return unite#start(['tweetvim'], {
        \ 'source__tweet' : tweet,
        \ })
endfunction


function! s:source.gather_candidates(args, context)
  return [
        \ {
        \  'word'           : 'retweet',
        \  'source__tweet'  : a:context.source__tweet,
        \  'source__action' : 'retweet',
        \ }
        \ ]
endfunction


let s:source.action_table.execute = {'description' : 'execute action'}
function! s:source.action_table.execute.func(candidate)
  echo a:candidate.source__tweet
endfunction

