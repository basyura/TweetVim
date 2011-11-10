"
"
"
function! tweetvim#say#open(...)
  let text  = a:0 > 0 ? a:1 : ''
  let param = a:0 > 1 ? a:2 : {}
  
  let bufnr = bufwinnr('tweetvim_say')
  if bufnr > 0
    exec bufnr.'wincmd w'
  else
    execute 'below split unite_twitter' 
    execute '2 wincmd _'
  endif
  setlocal modifiable
  silent %delete _
  call append(0, text)
  let b:tweetvim_post_param = param
  let &filetype = 'tweetvim_say'
  startinsert!
endfunction
"
"
"
augroup tweetvim_say
  autocmd! tweetvim_say
  autocmd FileType    tweetvim_say call s:tweetvim_say_settings()
  autocmd BufWinLeave tweetvim_say call s:tweetvim_say_leave()
augroup END


function! s:tweetvim_say_settings()
  setlocal bufhidden=wipe
  setlocal nobuflisted
  setlocal noswapfile
  setlocal modifiable
  setlocal nomodified
  nnoremap <buffer> <silent> q :bd!<CR>
  nnoremap <buffer> <silent> <C-s>      :call <SID>show_history()<CR>0
  inoremap <buffer> <silent> <C-s> <ESC>:call <SID>show_history()<CR>0
  nnoremap <buffer> <silent> <CR>       :call <SID>post_tweet()<CR>
  
  :0
  startinsert!
  " i want to judge by buffer variable
  if !exists('s:tweetvim_bufwrite_cmd')
    autocmd BufWriteCmd <buffer> echo 'please enter to tweet'
    let s:tweetvim_bufwrite_cmd = 1
  endif
endfunction

" for recovery tweet
let s:history = []

function! s:show_history()
  let no = len(s:history)
  if(no == 0)
    return
  endif
  let no = (exists('b:history_no') ? b:history_no : no) - 1
  if no == -1
    let no = len(s:history) - 1
  endif
  silent %delete _
  silent execute 'normal i' . s:history[no]
  let b:history_no = no
endfunction

function! s:save_history_at_leave()
  if &modifiable != 1
    return
  endif
  let msg = join(getline(1, "$"))
  if msg !~ '^\s\?$' && (len(s:history) == 0 || s:history[-1] != msg)
    call add(s:history , msg)
  endif
endfunction
"
"
"
function! s:post_tweet()
  let text  = join(getline(1, "$"))
  if strchars(text) > 140
    "call unite#util#print_error("over 140 chars")
    echohl Error | echo "over 140 chars" | echohl None
    return
  endif
  redraw | echo 'sending ... ' | sleep 1
  try
    let param = exists("b:tweetvim_post_param") ? b:tweetvim_post_param : {}
    call tweetvim#update(text, param)
  catch
    echoerr v:exception
    return
  endtry
  bd!
  redraw | echo 'sending ... ok'
endfunction
