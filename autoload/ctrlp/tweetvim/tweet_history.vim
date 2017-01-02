if exists('g:loaded_ctrlp_tweetvim_tweet_history') && g:loaded_ctrlp_tweetvim_tweet_history
  finish
endif
if !exists(":CtrlP")
    finish
endif
let g:loaded_ctrlp_tweetvim_tweet_history = 1

let s:tweet_history_var = {
            \ 'init': 'ctrlp#tweetvim#tweet_history#init()',
            \ 'exit': 'ctrlp#tweetvim#tweet_history#exit()',
            \ 'accept': 'ctrlp#tweetvim#tweet_history#accept',
            \ 'lname': 'tweet_history',
            \ 'sname': 'tweet_history',
            \ 'type': 'tweet_history',
            \ 'sort': 0,
            \}

if exists('g:ctrlp_ext_vars') && !empty(g:ctrlp_ext_vars)
    let g:ctrlp_ext_vars = add(g:ctrlp_ext_vars, s:tweet_history_var)
else
    let g:ctrlp_ext_vars = [s:tweet_history_var]
endif

function! ctrlp#tweetvim#tweet_history#init()
  return tweetvim#say#history()
endfunc

function! ctrlp#tweetvim#tweet_history#accept(mode, str)
  call ctrlp#exit()
  silent %delete _
  call setline(1,a:str)
endfunction

function! ctrlp#tweetvim#tweet_history#exit()
endfunction

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
function! ctrlp#tweetvim#tweet_history#id()
    return s:id
endfunction
