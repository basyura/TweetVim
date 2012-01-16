
let s:backup = []

let s:buf_name = '[tweetvim]'
"
"
"
function! tweetvim#buffer#load(method, args, title, tweets, ...)

  let args = copy(a:args)
  let opt  = a:0 ? copy(a:1) : {}

  call s:switch_buffer()
  call s:pre_process()
  call s:process(a:method, args, a:title, a:tweets, opt)
  call s:post_process()

  call s:backup(a:method, args, a:title, a:tweets, opt)

  let b:tweetvim_bufno = -1

   " define syntax
   let screen_name = tweetvim#verify_credentials().screen_name
   execute "syntax match tweetvim_reply '@" . screen_name . "'"
endfunction
"
"
"
function! tweetvim#buffer#previous()
  if len(s:backup) <= (b:tweetvim_bufno * -1)
    return
  endif

  let bufno = b:tweetvim_bufno - 1
  let pre   = s:backup[bufno]

  call tweetvim#buffer#load(pre.method, pre.args, pre.title, pre.tweets, pre.opt)
  " TODO delete duprecate backup
  let s:backup = s:backup[0:-2]
  let b:tweetvim_bufno = bufno
endfunction
"
"
"
function! tweetvim#buffer#next()
  if b:tweetvim_bufno == -1
    return
  endif

  let bufno = b:tweetvim_bufno + 1
  let pre   = s:backup[bufno]

  call tweetvim#buffer#load(pre.method, pre.args, pre.title, pre.tweets, pre.opt)
  " TODO
  let s:backup = s:backup[0:-2]
  let b:tweetvim_bufno = bufno
endfunction
"
"
"
function! tweetvim#buffer#replace(lineno, tweet)
  let colno  = col('.')
  let lineno = line('.')
  setlocal modifiable
  call cursor(a:lineno, colno)
  normal dd
  call append(a:lineno - 1, type(a:tweet) == 4 ? s:format(a:tweet) : a:tweet)
  setlocal nomodified
  setlocal nomodifiable
  call cursor(lineno, colno)
endfunction
"
"
"
function! tweetvim#buffer#truncate_backup(size)
  " TODO: truncate tail
  if a:size < 0
    let s:backup = eval('s:backup[:' . string(a:size) . ']')
    return
  endif

  if len(s:backup) <= a:size
    return
  endif
  let start = len(s:backup) - a:size
  " TODO:
  let s:backup = eval('s:backup[' . string(start) . ':]')
endfunction
"
"
"
function! s:backup(method, args, title, tweets, opt)
  call add(s:backup, {
        \ 'method' : a:method,
        \ 'args'   : a:args,
        \ 'title'  : a:title,
        \ 'tweets' : a:tweets,
        \ 'opt'    : a:opt,
        \ })
  " truncate
  call tweetvim#buffer#truncate_backup(g:tweetvim_cache_size)
endfunction
"
"
"
function! s:switch_buffer()
  let exist_win = 0

  " TODO : find window or buffer
  " buf_name is [tweetvim] or [tweetvim - in_replly_to]
  let winnr = 1
  while winnr <= winnr('$')
    if getbufvar(winbufnr(winnr), '&filetype') ==# 'tweetvim'
      execute winnr 'wincmd w'
      let exist_win = 1
      break
    endif
    let winnr += 1
  endwhile

  execute 'edit! ' . s:buf_name

  return

  " バッファの判定がよくわかんねぇ
  " s:bufnr の下りが 4[s] ぐらいかかっちゃうのとでひとまず

  if !exist_win
    let bufno = s:bufnr(escape(s:buf_name, '*[]?{},'))
    if bufno > 0
      execute 'buffer ' . bufno
    else
      execute 'edit! ' . s:buf_name
    endif
  endif
endfunction
"
"
"
function! s:pre_process()
  setlocal noswapfile
  setlocal modifiable
  setlocal buftype=nofile
  call s:define_default_key_mappings()
  setfiletype tweetvim
  silent %delete _
endfunction
"
"
"
function! s:process(method, args, title, tweets, opt)
  let b:tweetvim_method = a:method
  let b:tweetvim_args   = a:args
  let b:tweetvim_status_cache = {}

  let title = '[tweetvim]  - ' . a:title
  " add page no
  if !empty(a:args) && type(a:args[-1]) == 4
    let page = get(a:args[-1], 'page', 1)
    if page != 1
      let title .= ' : page ' . string(page)
    endif
  endif

  :0

  call append(0, title)
  call append(1, tweetvim#util#separator('~'))

  if get(a:opt, 'user_detail', 0)
    let user = a:tweets[0].user
    call append(line('$') - 1, '  @' . user.screen_name)
    for desc in split(user.description, '\n')
      call append(line('$') - 1, '  ' . substitute(desc, '', "", "g"))
    endfor
    call append(line('$') - 1, '  ' . user.url)
    call append(line('$') - 1, '  statuses  : ' . string(user.statuses_count))
    call append(line('$') - 1, '  friends   : ' . string(user.friends_count))
    call append(line('$') - 1, '  followers : ' . string(user.followers_count))
    call append(line('$') - 1, tweetvim#util#separator('~'))
  endif

  call s:append_tweets(a:tweets, b:tweetvim_status_cache)
  normal dd
  :0
endfunction
"
"
"
function! s:post_process()
  setlocal nomodified
  setlocal nomodifiable
endfunction
"
"
"
function! s:append_tweets(tweets, cache)
  let separator = tweetvim#util#separator('-')
  for tweet in a:tweets
    " cache tweet by line no
    let a:cache[line(".")] = tweet
    call append(line('$') - 1, s:format(tweet))
    call append(line('$') - 1, separator)
  endfor
endfunction
"
"
"
function! s:bufnr(buf_name)
  return bufexists(substitute(substitute(a:buf_name, '[', '\\[', 'g'), ']', '\\]', 'g') . '$')
endfunction
"
"
"
function! s:format(tweet)
  let text = a:tweet.text
  let text = substitute(text , '' , '' , 'g')
  let text = substitute(text , '\n' , '' , 'g')
  let text = tweetvim#util#unescape(text)

  let str  = tweetvim#util#padding(a:tweet.user.screen_name, 15) . ' : '
  " TODO
  if a:tweet.favorited && !has_key(a:tweet, 'retweeted_status')
    let str .= '★ '
  endif
  let str .= text
  let rt_count = get(a:tweet, 'retweet_count', 0)
  if rt_count
    let str .= ' ' . string(rt_count) . 'RT'
  endif
  " soruce
  if g:tweetvim_display_source
    " unescape for search api
    let source = matchstr(tweetvim#util#unescape(a:tweet.source), '>\zs.*\ze<')
    if source == ""
      let source = a:tweet.source
    endif
    let str .= ' [[from ' . source . ']]'
  endif
  if executable('php')
    let created_at = get(a:tweet, 'created_at', '')
    let created_at = system("php -r 'echo date(".'"y/m/d H:i:s", strtotime("'.created_at.'"));'."' 2>/dev/null")
    let str .= ' - ' . created_at
  endif

  return str
endfunction
"
"
"
function! s:screen_name()
  return tweetvim#verify_credentials().screen_name
endfunction

function! s:define_default_key_mappings()
  augroup tweetvim
    nmap <silent> <buffer> <CR>       <Plug>(tweetvim_action_enter)
    nmap <silent> <buffer> r  <Plug>(tweetvim_action_reply)
    nmap <silent> <buffer> i  <Plug>(tweetvim_action_in_reply_to)
    nmap <silent> <buffer> u  <Plug>(tweetvim_action_user_timeline)
    nmap <silent> <buffer> o  <Plug>(tweetvim_action_open_links)
    nmap <silent> <buffer> q  <Plug>(tweetvim_action_search)
    nmap <silent> <buffer> <leader>f  <Plug>(tweetvim_action_favorite)
    nmap <silent> <buffer> <leader>uf <Plug>(tweetvim_action_remove_favorite)
    nmap <silent> <buffer> <leader>r  <Plug>(tweetvim_action_retweet)
    nmap <silent> <buffer> <leader>q  <Plug>(tweetvim_action_qt)
    nmap <silent> <buffer> <Leader><Leader>  <Plug>(tweetvim_action_reload)

    nmap <silent> <buffer> ff  <Plug>(tweetvim_action_page_next)
    nmap <silent> <buffer> bb  <Plug>(tweetvim_action_page_previous)

    nmap <silent> <buffer> H  <Plug>(tweetvim_action_buffer_previous)
    nmap <silent> <buffer> L  <Plug>(tweetvim_action_buffer_next)

    nnoremap <silent> <buffer> a :call unite#sources#tweetvim_action#start()<CR>
    nnoremap <silent> <buffer> t :call unite#sources#tweetvim_timeline#start()<CR>
  augroup END
endfunction
