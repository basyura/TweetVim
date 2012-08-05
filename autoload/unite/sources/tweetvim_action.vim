
function! unite#sources#tweetvim_action#define()
  return s:source
endfunction

let s:source = {
      \ 'name': 'tweetvim/action',
      \ 'hooks' : {},
      \ 'action_table' : {},
      \ 'default_action' : {'common' : 'execute'},
      \ 'is_listed' : 0,
      \ }

function! unite#sources#tweetvim_action#start()
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

  return unite#start(['tweetvim/action'], {
        \ 'source__tweet' : tweet,
        \ })
endfunction


function! s:source.gather_candidates(args, context)
  if !has_key(a:context, 'source__tweet')
    return []
  endif

  let rel_path = 'autoload/tweetvim/action/*.vim'
  let actions  = map(split(globpath(&runtimepath, rel_path), "\<NL>") , 
                     \ 'fnamemodify(v:val , ":t:r")')

  let list = []
  for v in actions
    let Fn = function('tweetvim#action#' . v . '#define')
    let candidate = Fn()
    " do not list to candidates
    if get(candidate, 'source__is__list', 1) == 0
      continue
    endif
    if !has_key(candidate, 'word')
      let candidate.word = v
    endif
    if has_key(candidate, 'description')
      let candidate.abbr = tweetvim#util#padding(candidate.word, 15) 
                                              \ . ' - ' . candidate.description
    endif
    let candidate.source__action = v
    let candidate.source__tweet  = a:context.source__tweet
    call add(list, candidate)
  endfor

  return list
endfunction


let s:source.action_table.execute = {'description' : 'execute action'}
function! s:source.action_table.execute.func(candidate)
  let Fn = function('tweetvim#action#' . a:candidate.source__action . '#execute')
  call Fn(a:candidate.source__tweet)
endfunction

