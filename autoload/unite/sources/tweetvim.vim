
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
    echo "no action"
    return ''
  endif

  return unite#start(['tweetvim'], {
        \ 'source__tweet' : tweet,
        \ })
endfunction


function! s:source.gather_candidates(args, context)
  let rel_path = 'autoload/tweetvim/action/*.vim'
  let actions  = map(split(globpath(&runtimepath, rel_path), "\<NL>") , 
                     \ 'fnamemodify(v:val , ":t:r")')

  return map(actions, '{
        \ "word"          : v:val ,
        \ "source__tweet" : a:context.source__tweet
        \ }')

endfunction


let s:source.action_table.execute = {'description' : 'execute action'}
function! s:source.action_table.execute.func(candidate)
  let Fn = function('tweetvim#action#' . a:candidate.word . '#execute')
  call Fn(a:candidate.source__tweet)
endfunction

