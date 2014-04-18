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
    execute g:tweetvim_open_say_cmd . ' tweetvim_say'
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

  if text == '' && g:tweetvim_appendix != ''
    call append(0, g:tweetvim_appendix)
    delete _
    call cursor(1, 1)
  endif

  if g:tweetvim_say_insert_account
    call setline(1, '[' . tweetvim#account#current().screen_name . '] : ' . getline(1))
  endif

  let b:tweetvim_post_param = param
  let &filetype = 'tweetvim_say'

  if g:tweetvim_appendix != '' && getline('.') == g:tweetvim_appendix
    startinsert
  else
    startinsert!
  endif


  setlocal nomodified
endfunction
"
"
"
function! tweetvim#say#open_with_account(...)
  if a:0
    if !empty(tweetvim#account#current(a:1))
      call tweetvim#say#open()
    endif
  else
    call tweetvim#say#open()
  endif
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
  if !g:tweetvim_silent_say
    if input('ok ? [y/n] : ') != 'y'
      redraw | echo '' | return
    endif
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
function! s:tweetvim_say_settings()
  setlocal bufhidden=wipe
  setlocal nobuflisted
  setlocal noswapfile
  setlocal modifiable
  setlocal nomodified
  setlocal nonumber

  call s:update_char_count()
  augroup TweetVimSayCount
    autocmd! CursorMoved,CursorMovedI <buffer> call s:update_char_count()
  augroup END
  setlocal statusline=tweetvim_say\ :\ %{tweetvim#account#current().screen_name}\ %{b:tweetvim_say_count}

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

function! tweetvim#say#show_history()
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
function! tweetvim#say#post_buffer_tweet()
  let text = s:get_text()
  if s:post_tweet(text)
    bd!
  endif
endfunction
"
"
"
function! s:post_tweet(text)
  let text = a:text
  if text == ''
    echohl Error | echo "status is blank" | echohl None
    return 1
  endif
  if tweetvim#tweet#count_chars(text) < 0
    echohl Error
    let ret = input("over 140 chars ... tweet ? (y/n) : ")
    echohl None
    if ret != 'y'
      return
    endif
    redraw
  endif
  redraw | echo 'sending ... '
  try
    let param = exists("b:tweetvim_post_param") ? b:tweetvim_post_param : {}
    let res   = tweetvim#update(text, param)
    if has_key(res, 'error')
      redraw | echohl ErrorMsg | echo res.error | echohl None
      return 0
    endif
  catch
    redraw | echohl ErrorMsg | echo 'failed to update' | echohl None

    return 0
  endtry
  " write cache
  call s:write_hash_tag(text)
  " check async
  if !get(res, 'isAsync', 0)
    redraw | echo 'sending ... ok'
  endif
  return 1
endfunction

function! s:get_text()
  let text = matchstr(join(getline(1, '$'), "\n"), '^\_s*\zs\_.\{-}\ze\_s*$')
  let screen_name = tweetvim#account#current().screen_name
  return substitute(text, '^\[' . screen_name . '\] : ', '', '')
endfunction

function! s:update_char_count()
  let b:tweetvim_say_count = '[' . tweetvim#tweet#count_chars(s:get_text()) . ']'
endfunction

function! s:define_default_key_mappings()
  if g:tweetvim_no_default_key_mappings
    return
  endif
  augroup tweetvim_say
    nnoremap <buffer> <silent> q :bd!<CR>
    nmap <buffer> <silent> <C-s>       <Plug>(tweetvim_say_show_history)
    imap <buffer> <silent> <C-s>  <ESC><Plug>(tweetvim_say_show_history)
    nmap <buffer> <silent> <CR>        <Plug>(tweetvim_say_post_buffer)
    imap <buffer> <silent> <C-CR> <ESC><Plug>(tweetvim_say_post_buffer)

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
