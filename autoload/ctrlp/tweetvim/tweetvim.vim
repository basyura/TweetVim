" ctrlp plugin for tweetvim
"
if exists('g:loaded_ctrlp_tweetvim') && g:loaded_ctrlp_tweetvim
  finish
endif
if !exists(":CtrlP")
    finish
endif
let g:loaded_ctrlp_tweetvim = 1


let s:tweetvim_var = {
            \ 'init': 'ctrlp#tweetvim#tweetvim#init()',
            \ 'exit': 'ctrlp#tweetvim#tweetvim#exit()',
            \ 'accept': 'ctrlp#tweetvim#tweetvim#accept',
            \ 'enter': 'ctrlp#tweetvim#tweetvim#enter()',
            \ 'lname': 'tweetvim',
            \ 'sname': 'tweetvim',
            \ 'type': 'tweetvim',
            \ 'sort': 0,
            \}

if exists('g:ctrlp_ext_vars') && !empty(g:ctrlp_ext_vars)
    let g:ctrlp_ext_vars = add(g:ctrlp_ext_vars, s:tweetvim_var)
else
    let g:ctrlp_ext_vars = [s:tweetvim_var]
endif

let s:current_tweet = {}
function! ctrlp#tweetvim#tweetvim#enter()
  let s:current_tweet = tweetvim#buffer#get_status_cache(line('.'))
endfunction

function! ctrlp#tweetvim#tweetvim#init()

  if empty(s:current_tweet)
    return []
  endif

  let rel_path = 'autoload/tweetvim/action/*.vim'
  let actions  = map(split(globpath(&runtimepath, rel_path), "\<NL>") , 
                     \ 'fnamemodify(v:val , ":t:r")')

  let listcandidates = []
  for v in actions
    let Fn = function('tweetvim#action#' . v . '#define')
    let candidate = Fn()
    " do not list to candidates
    if get(candidate, 'source__is__list', 1) == 0
      continue
    endif
    call add(listcandidates, v)
  endfor

  return listcandidates
endfunc

function! ctrlp#tweetvim#tweetvim#accept(mode, str)
  let current_tweet = s:current_tweet
  call ctrlp#exit()
  let Fn = function('tweetvim#action#' . a:str . '#execute')
  call Fn(current_tweet)
endfunction

function! ctrlp#tweetvim#tweetvim#exit()
  unlet s:current_tweet
endfunction

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
function! ctrlp#tweetvim#tweetvim#id()
    return s:id
endfunction
