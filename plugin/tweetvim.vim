if exists('g:loaded_tweetvim')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim
"
"
"
function! s:set_global_variable(key, default)
  if !has_key(g:, a:key)
    let g:[a:key] = a:default
  endif
endfunction
"
"
"
function! s:http_get(url)
  return twibill#http#get(a:url)
endfunction
"
"
"
call s:set_global_variable('tweetvim_tweet_per_page'         , 20)
call s:set_global_variable('tweetvim_cache_size'             , 10)
call s:set_global_variable('tweetvim_config_dir'             , expand('~/.tweetvim'))
call s:set_global_variable('tweetvim_display_source'         , 0)
call s:set_global_variable('tweetvim_display_time'           , 1)
call s:set_global_variable('tweetvim_display_separator'      , 1)
call s:set_global_variable('tweetvim_display_icon'           , 0)
call s:set_global_variable('tweetvim_display_username'       , 0)
call s:set_global_variable('tweetvim_align_right'            , 0)
call s:set_global_variable('tweetvim_log'                    , 0)
call s:set_global_variable('tweetvim_open_buffer_cmd'        , 'edit!')
call s:set_global_variable('tweetvim_buffer_name'            , '[tweetvim]')
call s:set_global_variable('tweetvim_open_say_cmd'           , 'botright split')
call s:set_global_variable('tweetvim_footer'                 , '')
call s:set_global_variable('tweetvim_appendix'               , '')
call s:set_global_variable('tweetvim_default_account'        , '')
call s:set_global_variable('tweetvim_say_insert_account'     , 0)
call s:set_global_variable('tweetvim_async_post'             , 0)
call s:set_global_variable('tweetvim_silent_say'             , 0)
call s:set_global_variable('tweetvim_expand_t_co'            , 0)
call s:set_global_variable('tweetvim_debug'                  , 0)
call s:set_global_variable('tweetvim_updatetime'             , 500)
call s:set_global_variable('tweetvim_no_default_key_mappings', 0)
call s:set_global_variable('tweetvim_empty_separator'        , 0)
call s:set_global_variable('tweetvim_reconnect_seconds'      , 500)

if !isdirectory(g:tweetvim_config_dir)
  call mkdir(g:tweetvim_config_dir, 'p')
endif

if !isdirectory(g:tweetvim_config_dir . '/ico')
  call mkdir(g:tweetvim_config_dir . '/ico', 'p')
endif

if !isdirectory(g:tweetvim_config_dir . '/accounts')
  call mkdir(g:tweetvim_config_dir . '/accounts', 'p')
endif
"
"
command! TweetVimVersion :echo tweetvim#version()
"
command! TweetVimAccessToken  :call tweetvim#account#access_token()
"
command! TweetVimHomeTimeline :call tweetvim#timeline('home_timeline')
"
command! TweetVimMentions     :call tweetvim#timeline('mentions')
"
command! -nargs=1 -complete=custom,tweetvim#complete#list TweetVimListStatuses :call tweetvim#timeline('list_statuses', tweetvim#account#current().screen_name, <f-args>)
"
command! -nargs=1 -complete=custom,tweetvim#complete#screen_name TweetVimUserTimeline :call tweetvim#timeline('user_timeline', <f-args>)
"
command! -nargs=1 -complete=custom,tweetvim#complete#search TweetVimSearch :call tweetvim#timeline('search', <f-args>)
" tweet with say buffer
command! -nargs=? -complete=custom,tweetvim#complete#account TweetVimSay :call tweetvim#say#open_with_account(<f-args>)
" tweet with command line
command! -nargs=? TweetVimCommandSay :call tweetvim#say#command(<f-args>)
" tweet current line
command! TweetVimCurrentLineSay :call tweetvim#say#current_line()
" switch account
command! -nargs=1 -complete=custom,tweetvim#complete#account TweetVimSwitchAccount call tweetvim#account#current(<f-args>)
" add account
command! TweetVimAddAccount call tweetvim#account#add()
" user stream
command! -nargs=* -bang TweetVimUserStream call tweetvim#userstream(<bang>0, <f-args>)
" clear icons from ~/.tweetvim/ico
command! -nargs=? TweetVimClearIcon call tweetvim#util#clear_icon(<f-args>)

if globpath(&runtimepath, 'autoload/bitly.vim') != ''
  command! TweetVimBitly :call <SID>shorten_url()
endif

function! s:shorten_url()

  if &filetype != 'tweetvim_say'
    echo 'tweetvim_say buffer only'
    return
  endif

  let url = input("URL to shorten: ")
  if url == ""
    echo "No URL provided."
    return
  endif

  let col = col('.')
  if col != 1
    let col += 1
  endif
  let row = line('.')

  let shorturl = bitly#shorten(url).url
  let content = s:http_get(url).content
  let charset = matchstr(content , 'charset=\zs.\{-}\ze".\{-}>')
  " title
  let title = iconv(matchstr(content , '<title>\zs.\{-}\ze</title>') ,
        \ charset , 'utf-8')
  let title = tweetvim#util#trim(substitute(title, '\n', '', 'g'))
  " url
  let shorturl = '> ' . title . ' ' . shorturl
  execute "normal! a".shorturl."\<esc>"
  call cursor(row, col)
  startinsert
endfunction

nnoremap <silent> <Plug>(tweetvim_action_enter)           :<C-u>call tweetvim#action('enter')<CR>
nnoremap <silent> <Plug>(tweetvim_action_reply)           :<C-u>call tweetvim#action('reply')<CR>
nnoremap <silent> <Plug>(tweetvim_action_reply_to_all)    :<C-u>call tweetvim#action('reply_to_all')<CR>
nnoremap <silent> <Plug>(tweetvim_action_in_reply_to)     :<C-u>call tweetvim#action('in_reply_to')<CR>
nnoremap <silent> <Plug>(tweetvim_action_user_timeline)   :<C-u>call tweetvim#action('user_timeline')<CR>
nnoremap <silent> <Plug>(tweetvim_action_favorite)        :<C-u>call tweetvim#action('favorite')<CR>
nnoremap <silent> <Plug>(tweetvim_action_remove_favorite) :<C-U>call tweetvim#action('remove_favorite')<CR>
nnoremap <silent> <Plug>(tweetvim_action_retweet)         :<C-u>call tweetvim#action('retweet')<CR>
nnoremap <silent> <Plug>(tweetvim_action_qt)              :<C-u>call tweetvim#action('qt')<CR>
nnoremap <silent> <Plug>(tweetvim_action_reload)          :<C-u>call tweetvim#action('reload')<CR>
nnoremap <silent> <Plug>(tweetvim_action_page_next)       :<C-u>call tweetvim#action('page_next')<CR>
nnoremap <silent> <Plug>(tweetvim_action_page_previous)   :<C-u>call tweetvim#action('page_previous')<CR>
nnoremap <silent> <Plug>(tweetvim_action_buffer_previous) :<C-u>call tweetvim#action('buffer_previous')<CR>
nnoremap <silent> <Plug>(tweetvim_action_buffer_next)     :<C-u>call tweetvim#action('buffer_next')<CR>
nnoremap <silent> <Plug>(tweetvim_action_open_links)      :<C-u>call tweetvim#action('open_links')<CR>
nnoremap <silent> <Plug>(tweetvim_action_open_prev_links) :<C-u>call tweetvim#action('open_prev_links')<CR>
nnoremap <silent> <Plug>(tweetvim_action_search)          :<C-u>call tweetvim#action('search')<CR>
nnoremap <silent> <Plug>(tweetvim_action_remove_status)   :<C-u>call tweetvim#action('remove_status')<CR>
nnoremap <silent> <Plug>(tweetvim_action_expand_url)      :<C-u>call tweetvim#action('expand_url')<CR>
nnoremap <silent> <Plug>(tweetvim_action_cursor_up)       :<C-u>call tweetvim#action('cursor_up')<CR>
nnoremap <silent> <Plug>(tweetvim_action_cursor_down)     :<C-u>call tweetvim#action('cursor_down')<CR>
nnoremap <silent> <Plug>(tweetvim_action_favstar)         :<C-u>call tweetvim#action('favstar')<CR>
nnoremap <silent> <Plug>(tweetvim_action_favstar_browser) :<C-u>call tweetvim#action('favstar_browser')<CR>

nnoremap <silent> <Plug>(tweetvim_action_buffer_previous_stream) :<C-u>call tweetvim#action('buffer_previous_stream')<CR>

nnoremap <silent> <Plug>(tweetvim_say_post_buffer)        :<C-u>call tweetvim#say#post_buffer_tweet()<CR>
nnoremap <silent> <Plug>(tweetvim_say_show_history)       :<C-u>call tweetvim#say#show_history()<CR>

" for multi account

if filereadable(g:tweetvim_config_dir . '/token')
   command! TweetVimMigration :call tweetvim#migration#execute()
   :TweetVimMigration
endif


let g:loaded_tweetvim = 1

let &cpo = s:save_cpo
unlet s:save_cpo
