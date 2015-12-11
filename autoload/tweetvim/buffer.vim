scriptencoding utf-8

let s:backup = []
let s:signs  = {}

let s:buf_name = g:tweetvim_buffer_name

let s:last_bufnr = 0
"
"
"
function! tweetvim#buffer#load(method, args, title, tweets, ...)

  if get(b:, 'tweetvim_method', '') == 'userstream'
    call s:backup('userstream', [], 'userstream', s:sort_values(b:tweetvim_status_cache), {})
  endif

  call s:unsigns()

  let args = copy(a:args)
  let opt  = a:0 ? copy(a:1) : {}

  call s:backup(a:method, args, a:title, a:tweets, opt)

  call s:switch_buffer()
  call s:pre_process()
  call s:process(a:method, args, a:title, a:tweets, opt)
  call s:post_process()

  let b:tweetvim_bufno = -1

  " define syntax
  call s:apply_syntax()
endfunction

function! s:sort_values(m)
  let list = []
  for v in sort(keys(a:m), 's:nr_comparator')
    call add(list, a:m[v])
  endfor
  return list
endfunction
"
"
function! s:nr_comparator(i1, i2)
  return a:i1 == a:i2 ? 0 : str2nr(a:i1) > str2nr(a:i2) ? 1 : -1
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
function! tweetvim#buffer#previous_stream()
  if b:tweetvim_method == 'userstream'
    echo "already in userstream"
    return
  endif
  let bufno = len(s:backup) - 1
  while bufno >= 0
    let pre   = s:backup[bufno]
    if pre.method == 'userstream'
      call tweetvim#buffer#load(pre.method, pre.args, pre.title, pre.tweets, pre.opt)
      let s:backup = s:backup[0:bufno]
      let b:tweetvim_bufno = -1
      echo "backed to userstream"
      return
    endif
    let bufno -= 1
  endwhile

  echo "no stream buffer"

endfunction
"
"
"
function! tweetvim#buffer#replace(lineno, tweet)
  let colno  = col('.')
  let lineno = line('.')
  setlocal modifiable
  call cursor(a:lineno, 1)

  normal! "_D

  let word = type(a:tweet) == 4 ? s:format(a:tweet, 0) : a:tweet
  " temporary fix
  let word = substitute(split(word, '\n')[0], '', "", "g")

  " this copy logic is from unite.vim
  let old_reg = [getreg('"'), getregtype('"')]
  call setreg('"', word)
  try
    execute 'normal! ""p'
  finally
    call setreg('"', old_reg[0], old_reg[1])
  endtry

  setlocal nomodified
  setlocal nomodifiable
  call cursor(lineno, colno)
endfunction
"
"
"
function! tweetvim#buffer#append(tweet)
  let tweet  = a:tweet
  setlocal modifiable
  let today = tweetvim#util#today()
  if g:tweetvim_display_separator
    call s:append_separator(tweetvim#util#separator('-'), 0)
  endif

  "if has_key(tweet, 'event')
    "call append(line("$"), tweet.event)
    "return
  "endif

  let lineno = line("$")
  call s:append_text(tweet, today)
  " skip direct message to avoid accidents
  if !get(tweet, 'is_direct_message', 0)
    let b:tweetvim_status_cache[lineno] = tweet
  endif

  if g:tweetvim_display_icon && has('gui_running')
    call s:sign(tweet, lineno)
  endif
"  call s:apply_syntax()
  setlocal nomodifiable
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

function! tweetvim#buffer#userstream(title)
  
  call s:switch_buffer()
  call s:pre_process()

  if !exists('b:tweetvim_bufno')
    let b:tweetvim_bufno = -1
  endif

  let b:tweetvim_method = 'userstream'
  let b:tweetvim_status_cache = {}

  let title = s:buf_name . ' - ' . tweetvim#account#current().screen_name . ' - ' . a:title

  call append(0, title)
  call append(1, tweetvim#util#separator('~'))
  if g:tweetvim_display_separator
    delete _
  endif

  call s:apply_syntax()
  call s:post_process()
endfunction

"
"
"
function! s:backup(method, args, title, tweets, opt)

  if len(s:backup) > 0
    let s:backup[-1].opt.line = line('.')
  end

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
    execute 'silent ' . g:tweetvim_open_buffer_cmd . ' ' . s:buf_name
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
      execute 'silent ' . g:tweetvim_open_buffer_cmd
    endif
    execute 'buffer ' . bufnr
  else
    " buf is already deleted
    execute 'silent ' . g:tweetvim_open_buffer_cmd . ' ' . s:buf_name
    let s:last_bufnr = bufnr("")
  endif
endfunction
"
"
"
function! s:pre_process()

  if g:tweetvim_display_icon && has('gui_running')
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

  let title = s:buf_name . ' - ' . tweetvim#account#current().screen_name . ' - ' . a:title
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
    if user.url != '0'
      let url = user.entities.url.urls[0].expanded_url
      if url == '0'
        let url = user.url
      endif
      call append(line('$') - 1, '  ' . url)
    end
    call append(line('$') - 1, '  statuses  : ' . string(user.statuses_count))
    call append(line('$') - 1, '  friends   : ' . string(user.friends_count))
    call append(line('$') - 1, '  followers : ' . string(user.followers_count))
    call append(line('$') - 1, tweetvim#util#separator('~'))
  endif

  if g:tweetvim_display_icon && has('gui_running')
    call s:append_tweets_with_icon(a:tweets, b:tweetvim_status_cache)
  else
    call s:append_tweets(a:tweets, b:tweetvim_status_cache)
  endif
  delete _

  " cause remained old tweet ...
  if !g:tweetvim_display_separator
    call append(line('$'), '')
  endif

  let line = get(a:opt, 'line', 1)
  call cursor(line, 1)
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
    call s:append_text(tweet, today)
    call s:append_separator(separator)
  endfor
endfunction
"
"
"
function! s:append_tweets_with_icon(tweets, cache)
  let separator = tweetvim#util#separator('-')
  let today = tweetvim#util#today()

  for tweet in tweetvim#filter#execute(a:tweets)
    let a:cache[line(".")] = tweet
    let row = line(".")
    call s:append_text(tweet, today)
    call s:append_separator(separator)
    call s:sign(tweet, row)
  endfor

endfunction


function! s:unsigns()
  "for name in keys(s:signs)
    "execute ":sign undefine " . name
  "endfor
  let s:signs = {}
endfunction

function! s:sign(tweet, lineno)
  let tweet = a:tweet
  let current_dir = getcwd()

  execute "cd " . g:tweetvim_config_dir . '/ico'

  let screen_name = tweet.user.screen_name
  if has_key(tweet.user, 'profile_image_url')
    let img_url = tweet.user.profile_image_url
  else
    let img_url = tweet.profile_image_url
  endif
  let ico_path = g:tweetvim_config_dir . '/ico/' . screen_name . ".ico"

  if !filereadable(ico_path)
    let file_name = fnamemodify(img_url, ":t")
    call system("curl -L -O " . img_url)
    call system("convert " . file_name . " " . ico_path)
    call delete(file_name)
    redraw
  end

  try
    execute ":sign define tweetvim_icon_" . screen_name . " icon=" . ico_path
    execute ":sign place 1 line=" . a:lineno . " name=tweetvim_icon_" . screen_name . " buffer=" . bufnr("%")
    let s:signs["tweetvim_icon_" . screen_name] = 1
  catch
    echomsg v:errmsg
  endtry

  execute "cd " . current_dir
endfunction

let s:padding_left = '                  '
function! s:append_text(tweet, today, ...)
  let isquoted = a:0 > 0 ? a:1 : 0
  let text = s:format(a:tweet, isquoted, a:today)
  let isfirst = 1
  for line in split(text, "\n")
    let space = isfirst || g:tweetvim_display_username ? '' : s:padding_left
    if !isfirst && g:tweetvim_display_icon && has('gui_running')
      let space .= ' '
    endif
    call append(line('$') - 1, space . substitute(line, '' , '' , 'g'))
    let isfirst = 0
  endfor
  " added auoted statuses
  if has_key(a:tweet, 'quoted_status')
    call append(line('$') - 1, '')
    call s:append_text(a:tweet.quoted_status, a:today, 1)
  end
endfunction

function! s:append_separator(separator, ...)
  " TODO
  let diff = -1
  if a:0 > 0
    let diff = a:1
  endif
  " insert separator or not
  if g:tweetvim_empty_separator
    call append(line('$') + diff, "")
  elseif g:tweetvim_display_separator
    call append(line('$') + diff, a:separator)
  endif
endfunction
"
"
function! s:bufnr(buf_name)
  return bufexists(substitute(substitute(a:buf_name, '[', '\\[', 'g'), ']', '\\]', 'g') . '$')
endfunction

function! s:expand_t_co(text, status)
  let text = a:text
  if has_key(a:status, 'entities') && !empty(a:status.entities.urls)
    for u in a:status.entities.urls
      let text = substitute(text, '\M' . u.url, tweetvim#util#decodeURI(u.expanded_url), 'g')
    endfor
  endif
  return text
endfunction

"
"
"
function! s:format(tweet, isquoted, ...)
  let tweet = a:tweet
  let text = ''
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

  if has_key(tweet,'direct_message')
    " replace tweet properties
    call extend(tweet, {
          \ 'user'              : {'screen_name' : tweet.direct_message.sender_screen_name},
          \ 'profile_image_url' : tweet.direct_message.sender.profile_image_url,
          \ 'text'              : tweet.direct_message.text,
          \ 'favorited'         : 0,
          \ 'source'            : '',
          \ 'created_at'        : tweet.direct_message.created_at,
          \ 'is_direct_message' : 1,
          \})
    let text .= '[Direct Message] '
  endif

  if has_key(tweet, 'retweeted_status')
    let text = 'RT @' . tweet.retweeted_status.user.screen_name . ': '
    if stridx(tweet.retweeted_status.text, "\n") != -1
      let text .= "\n"
    endif
    let text .= tweet.retweeted_status.text
  else
    let text .= tweet.text
  endif

  " expand t.co url
  if g:tweetvim_expand_t_co
    let text = s:expand_t_co(text,
                \ has_key(tweet, 'retweeted_status') ? tweet.retweeted_status : tweet)
  end
  "let text = substitute(text , '' , '' , 'g')
  "let text = substitute(text , '\n' , '' , 'g')
  let text = tweetvim#util#unescape(text)

  let today = a:0 ? a:1 : tweetvim#util#today()

  if g:tweetvim_display_username
    let str  = tweet.user.name.' @'.tweet.user.screen_name."\n"
  elseif a:isquoted == 1
    if tweet.user.name != tweet.user.screen_name
      let str = tweetvim#util#padding('', 18) . tweet.user.name . ' @' . tweet.user.screen_name . "\n"
    else
      let str = tweetvim#util#padding('', 18) . tweet.user.screen_name . "\n"
    endif
  else
    let str  = tweetvim#util#padding(tweet.user.screen_name, 15) . ' : '
  endif
  " FIXME
  if g:tweetvim_display_icon && has('gui_running')
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
  let str_right = ''
  " soruce
  if g:tweetvim_display_source
    " unescape for search api
    let source = matchstr(tweetvim#util#unescape(tweet.source), '>\zs.*\ze<')
    if source == ""
      let source = tweet.source
    endif
    let str_right .= ' [[from ' . source . ']]'
  endif
  " time
  if get(g:, 'tweetvim_display_time', 1)
    try
      let date  = tweetvim#util#format_date(tweet.created_at)
      let date  = substitute(date, today, '', '')
      let str_right .= ' [[' . date . ']]'
    catch
      echo v:exception
      " serch と timeline でフォーマットが違う
    endtry
  endif

  if strlen(str_right)
    if g:tweetvim_align_right
      let strsplit = split(str, '\n')
      let icon = g:tweetvim_display_icon && has('gui_running')
      let padding =  len(strsplit) > 1 ? strlen(s:padding_left) + icon : 0
      let right_width = strdisplaywidth(str_right)
      if &l:number || (exists('&relativenumber') && &l:relativenumber)
        let number_width = max([&l:numberwidth, strlen(line('$') . '') + 1])
      else
        let number_width = 0
      endif
      let number_width += icon * 2
      let last_width = strdisplaywidth(strsplit[-1]) + padding + number_width
      let rest_width = winwidth(0) - number_width
      while last_width > rest_width
        let last_width -= rest_width
      endwhile
      let white_width = winwidth(0) - right_width - last_width
      let str .= repeat(' ', white_width + (white_width < 0 ? rest_width : 0) - 1) . str_right
    else
      let str .= str_right
    endif
  endif

  return str
endfunction

function! s:apply_syntax()
  syntax clear tweetvim_reply
  let screen_name = tweetvim#account#current().screen_name
  if b:tweetvim_method == 'mentions' || (b:tweetvim_method == 'user_timeline' && b:tweetvim_args[0] == screen_name)
    return
  endif
  execute 'syntax match tweetvim_reply "\zs.*\c@' . screen_name . '\_.\{-}\ze\s\[\["'
  execute 'syntax match tweetvim_reply "\zs.* : ★ by .*\ze"'
endfunction

function! s:define_default_key_mappings()
  if g:tweetvim_no_default_key_mappings
    return
  endif
  augroup tweetvim
    nmap <silent> <buffer> <CR>       <Plug>(tweetvim_action_enter)
    nmap <silent> <buffer> r  <Plug>(tweetvim_action_reply)
    nmap <silent> <buffer> R  <Plug>(tweetvim_action_reply_to_all)
    nmap <silent> <buffer> i  <Plug>(tweetvim_action_in_reply_to)
    nmap <silent> <buffer> u  <Plug>(tweetvim_action_user_timeline)
    nmap <silent> <buffer> o  <Plug>(tweetvim_action_open_links)
    nmap <silent> <buffer> O  <Plug>(tweetvim_action_open_prev_links)
    nmap <silent> <buffer> q  <Plug>(tweetvim_action_search)
    nmap <silent> <buffer> <leader>f  <Plug>(tweetvim_action_favorite)
    nmap <silent> <buffer> <leader>uf <Plug>(tweetvim_action_remove_favorite)
    nmap <silent> <buffer> <leader>r  <Plug>(tweetvim_action_retweet)
    nmap <silent> <buffer> <leader>q  <Plug>(tweetvim_action_qt)
    nmap <silent> <buffer> <leader>e  <Plug>(tweetvim_action_expand_url)
    nmap <silent> <buffer> <leader>F  <Plug>(tweetvim_action_favstar)
    nmap <silent> <buffer> <Leader><Leader>  <Plug>(tweetvim_action_reload)

    nmap <silent> <buffer> ff  <Plug>(tweetvim_action_page_next)
    nmap <silent> <buffer> bb  <Plug>(tweetvim_action_page_previous)

    nmap <silent> <buffer> H  <Plug>(tweetvim_action_buffer_previous)
    nmap <silent> <buffer> L  <Plug>(tweetvim_action_buffer_next)
    nmap <silent> <buffer> <Leader>s <Plug>(tweetvim_action_buffer_previous_stream)

    nmap <silent> <buffer> j <Plug>(tweetvim_action_cursor_down)
    nmap <silent> <buffer> k <Plug>(tweetvim_action_cursor_up)

    nnoremap <silent> <buffer> a :call unite#sources#tweetvim_action#start()<CR>
    nnoremap <silent> <buffer> t :call unite#sources#tweetvim_timeline#start()<CR>
    nnoremap <silent> <buffer> <leader>a :call unite#sources#tweetvim_switch_account#start()<CR>
  augroup END
endfunction
