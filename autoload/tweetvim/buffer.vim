scriptencoding utf-8

let s:backup = []

let s:buf_name = '[tweetvim]'

let s:last_bufnr = 0
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
   let screen_name = tweetvim#current_account()
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
function! tweetvim#buffer#prepend(tweets)
  let tweets = type(a:tweets) != 3 ? [a:tweets] : a:tweets

  call extend(reverse(tweets), b:tweetvim_status_cache)
  let title  = join(split(b:tweetvim_method, '_'), ' ')

  call tweetvim#buffer#load(b:tweetvim_method, b:tweetvim_args, title, tweets)
endfunction
"
"
"
function! tweetvim#buffer#get_status_cache(lineno)
  return get(b:tweetvim_status_cache, a:lineno, {})
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
  " get buf no from buffer's name
  let bufnr = -1
  let num   = bufnr('$')
  while num >= s:last_bufnr
    if getbufvar(num, '&filetype') ==# 'tweetvim'
      let bufnr = num
      break
    endif
    let num -= 1
  endwhile
  " buf is not exist
  if bufnr < 0
    execute g:tweetvim_open_buffer_cmd . ' ' . s:buf_name
    let s:last_bufnr = bufnr("")
    return
  endif
  " buf is exist in window
  let winnr = bufwinnr(bufnr)
  if winnr > 0
    execute winnr 'wincmd w'
    return
  endif
  " buf is exist
  if buflisted(bufnr)
    if g:tweetvim_open_buffer_cmd =~ "split"
      execute g:tweetvim_open_buffer_cmd
    endif
    execute 'buffer ' . bufnr
  else
    " buf is already deleted
    execute g:tweetvim_open_buffer_cmd . ' ' . s:buf_name
    let s:last_bufnr = bufnr("")
  endif
endfunction
"
"
"
function! s:pre_process()
  if g:tweetvim_display_icon
    setlocal nonu
    hi Signcolumn guibg=bg
  end

  setlocal noswapfile
  setlocal modifiable
  setlocal nolist
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

  let title = '[tweetvim]  - ' . tweetvim#current_account() . ' - ' . a:title
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

  if g:tweetvim_display_icon
    call s:append_tweets_with_icon(a:tweets, b:tweetvim_status_cache)
  else
    call s:append_tweets(a:tweets, b:tweetvim_status_cache)
  endif
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
  let today     = tweetvim#util#today()
  " filter tweets
  for tweet in tweetvim#filter#execute(a:tweets)
    " cache tweet by line no
    let a:cache[line(".")] = tweet
    call append(line('$') - 1, s:format(tweet, today))
    " insert separator or not
    if g:tweetvim_display_separator
      call append(line('$') - 1, separator)
    endif
  endfor
endfunction
"
"
"
function! s:append_tweets_with_icon(tweets, cache)
  let separator = tweetvim#util#separator('-')
  let today = tweetvim#util#today()

  let current_dir = getcwd()
  execute "cd " . g:tweetvim_config_dir . '/ico'

  let cmds = []
  for tweet in tweetvim#filter#execute(a:tweets)
    let a:cache[line(".")] = tweet
    call append(line('$') - 1, s:format(tweet, today))
    call append(line('$') - 1, separator)

    let screen_name = tweet.user.screen_name
    if has_key(tweet.user, 'profile_image_url')
      let img_url = tweet.user.profile_image_url
    else
      let img_url = tweet.profile_image_url
    endif
    let ico_path = g:tweetvim_config_dir . '/ico/' . screen_name . ".ico"
    let file_name = fnamemodify(img_url, ":t")

    if !filereadable(ico_path)
      echo "downloading ... " . img_url
      call system("curl -L -O " . img_url)
      call system("convert " . fnamemodify(img_url, ":t") . " " . ico_path)
      call delete(file_name)
      redraw
    end

    execute "cd " . current_dir

    call add(cmds, ":sign define tweetvim_icon_" . screen_name . " icon=" . ico_path)
    call add(cmds, ":sign place 1 line=" . (line(".") - 2) . " name=tweetvim_icon_" . screen_name . " buffer=" . bufnr("%"))
  endfor

  for cmd in cmds
    try
      execute cmd
    catch
      echomsg v:errmsg
    endtry
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
function! s:format(tweet, ...)
  let tweet = a:tweet
  " for protected user
  if has_key(a:tweet, 'error')
    let tweet = {
          \ 'user'       : {'screen_name' : 'unknown'},
          \ 'text'       : tweet.error, 
          \ 'favorited'  : 0,
          \ 'source'     : '',
          \ 'created_at' : '',
          \ }
  endif

  let text = has_key(tweet, 'retweeted_status')
              \ ? 'RT @' . tweet.retweeted_status.user.screen_name . ': ' . tweet.retweeted_status.text
              \ : tweet.text
  let text = substitute(text , '' , '' , 'g')
  let text = substitute(text , '\n' , '' , 'g')
  let text = tweetvim#util#unescape(text)

  let today = a:0 ? a:1 : tweetvim#util#today()

  let str  = tweetvim#util#padding(tweet.user.screen_name, 15) . ' : '
  " FIXME
  if g:tweetvim_display_icon
    let str = ' ' . str
  endif
  " TODO
  if tweet.favorited && !has_key(tweet, 'retweeted_status')
    let str .= '★ '
  endif
  let str .= text
  let rt_count = get(tweet, 'retweet_count', 0)
  if rt_count
    let str .= ' ' . string(rt_count) . 'RT'
  endif
  " soruce
  if g:tweetvim_display_source
    " unescape for search api
    let source = matchstr(tweetvim#util#unescape(tweet.source), '>\zs.*\ze<')
    if source == ""
      let source = tweet.source
    endif
    let str .= ' [[from ' . source . ']]'
  endif
  " time
  if get(g:, 'tweetvim_display_time', 1)
    try
      let date  = tweetvim#util#format_date(tweet.created_at)
      let date  = substitute(date, today, '', '')
      let str .= ' [[' . date . ']]'
    catch
      " serch と timeline でフォーマットが違う
    endtry
  endif

  return str
endfunction
"
"
"
function! s:screen_name()
  return tweetvim#current_account()
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
    nmap <silent> <buffer> <leader>e  <Plug>(tweetvim_action_expand_url)
    nmap <silent> <buffer> <Leader><Leader>  <Plug>(tweetvim_action_reload)

    nmap <silent> <buffer> ff  <Plug>(tweetvim_action_page_next)
    nmap <silent> <buffer> bb  <Plug>(tweetvim_action_page_previous)

    nmap <silent> <buffer> H  <Plug>(tweetvim_action_buffer_previous)
    nmap <silent> <buffer> L  <Plug>(tweetvim_action_buffer_next)

    nnoremap <silent> <buffer> a :call unite#sources#tweetvim_action#start()<CR>
    nnoremap <silent> <buffer> t :call unite#sources#tweetvim_timeline#start()<CR>
    nnoremap <silent> <buffer> <leader>a :call unite#sources#tweetvim_switch_account#start()<CR>
  augroup END  
endfunction
