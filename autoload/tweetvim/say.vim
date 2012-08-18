"
"
"
let s:tweet_history = []
function! tweetvim#say#history()
  return copy(s:tweet_history)
endfunction
"
" say with opened buffer
"
function! tweetvim#say#open(...)
  let text  = a:0 > 0 ? a:1 : ''
  let param = a:0 > 1 ? a:2 : {}
  
  let bufnr = bufwinnr('tweetvim_say')
  if bufnr > 0
    exec bufnr.'wincmd w'
  else
    execute 'below split tweetvim_say' 
    execute '2 wincmd _'
    call s:define_default_key_mappings()
    call s:tweetvim_say_settings()
  endif

  setlocal modifiable
  silent %delete _
  call setline(1, text)
  " added footer
  if text == '' && g:tweetvim_footer != ''
     silent $ put =g:tweetvim_footer
    call cursor(1, 1)
  endif
  let b:tweetvim_post_param = param

  let &filetype = 'tweetvim_say'
  startinsert!

  setlocal nomodified
endfunction
"
" say with command line
"
function! tweetvim#say#command(...)
  let msg = a:0 ? a:1 : input('tweet : ')
  " check msg
  if msg == ''
    redraw | echo '' | return
  endif
  " check post ok
  redraw
  echo msg
  if input('ok ? [y/n] : ') != 'y'
    redraw | echo '' | return
  endif
  " post
  call s:post_tweet(msg)
endfunction
"
" say from current line
"
function! tweetvim#say#current_line()
  call tweetvim#say#command(getline("."))
endfunction
"
"
"
"
function! tweetvim#say#count()
  return 140 - strchars(s:get_text())
endfunction
"
"
"
function! s:tweetvim_say_settings()
  setlocal bufhidden=wipe
  setlocal nobuflisted
  setlocal noswapfile
  setlocal modifiable
  setlocal nomodified

  call s:update_char_count()
  augroup TweetVimSayCount
    autocmd! CursorMoved,CursorMovedI <buffer> call s:update_char_count()
  augroup END
  setlocal statusline=tweetvim_say\ :\ %{tweetvim#current_account()}\ %{b:tweetvim_say_count}

  :0
  startinsert!
  " i want to judge by buffer variable
  if !exists('b:tweetvim_bufwrite_cmd')
    augroup TweetVimSay
      autocmd! TweetVimSay
      autocmd BufWriteCmd <buffer> echohl Error | echo 'please enter to tweet' | echohl None
    augroup END
    let b:tweetvim_bufwrite_cmd = 1
  endif
endfunction

function! s:tweetvim_say_leave()
  if &filetype != 'tweetvim_say'
    return
  endif
  call s:save_history_at_leave()
endfunction

function! s:show_history()
  if empty(s:tweet_history) || &filetype != 'tweetvim_say'
    return
  endif
  let no = exists('b:history_no') ? b:history_no + 1 : 0
  if no > len(s:tweet_history) - 1
    let no = 0
  endif
  silent %delete _
  silent execute 'normal i' . s:tweet_history[no]
  :0
  let b:history_no = no
endfunction

function! s:save_history_at_leave()
  if &modifiable != 1
    return
  endif
  let msg = join(getline(1, "$"))
  if msg !~ '^\s\?$' && (empty(s:tweet_history) || s:tweet_history[0] != msg)
    call insert(s:tweet_history , msg)
  endif
  " truncate
  let s:tweet_history = s:tweet_history[:10]
endfunction
"
"
"
function! s:post_buffer_tweet()
  let text = s:get_text()
  if s:post_tweet(text)
    bd!
  endif
endfunction
"
"
"
function! s:post_tweet(text)
  if strchars(a:text) > 140
    "call unite#util#print_error("over 140 chars")
    echohl Error | echo "over 140 chars" | echohl None
    return
  endif
  redraw | echo 'sending ... ' | sleep 1
  try
    let param = exists("b:tweetvim_post_param") ? b:tweetvim_post_param : {}
    let res   = tweetvim#update(a:text, param)
    if has_key(res, 'error')
      redraw | echohl ErrorMsg | echo res.error | echohl None
      return 0
    endif
  catch
    redraw | echohl ErrorMsg | echo 'failed to update' | echohl None
    return 0
  endtry
  call s:write_hash_tag(a:text)
  redraw | echo 'sending ... ok'
  return 1
endfunction

function! s:get_text()
  return matchstr(join(getline(1, '$'), "\n"), '^\_s*\zs\_.\{-}\ze\_s*$')
endfunction

function! s:update_char_count()
  let b:tweetvim_say_count = '[' . tweetvim#say#count() . ']'
endfunction

function! s:define_default_key_mappings()
  augroup tweetvim_say
    nnoremap <buffer> <silent> q :bd!<CR>
    nnoremap <buffer> <silent> <C-s>      :call <SID>show_history()<CR>
    inoremap <buffer> <silent> <C-s> <ESC>:call <SID>show_history()<CR>
    nnoremap <buffer> <silent> <CR>       :call <SID>post_buffer_tweet()<CR>

    inoremap <buffer> <silent> <C-i> <ESC>:call unite#sources#tweetvim_tweet_history#start()<CR>
    nnoremap <buffer> <silent> <C-i> <ESC>:call unite#sources#tweetvim_tweet_history#start()<CR>
    if exists(':TweetVimBitly')
      inoremap <buffer> <C-x><C-d> <ESC>:TweetVimBitly<CR>
    endif
    autocmd! BufWinLeave <buffer> call s:tweetvim_say_leave()
  augroup END
endfunction
"
"
"
function! s:write_hash_tag(text)
  let pattern = '[ 　。、]\zs[#＃][^ ].\{-1,}\ze[ \n]'
  let list = []
  let text = a:text . ' '
  while 1
    let tag = matchstr(text, pattern)
    if tag == ''
      break
    endif
    call add(list, substitute(tag, '[#＃]', '', ''))
    let text = substitute(text, tag, "", "")
  endwhile
  
  if len(list) != 0
    call tweetvim#cache#write('hash_tag', list)
  endif
endfunction
