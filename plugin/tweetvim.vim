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
  try
    let res = webapi#http#get(a:url)
  catch
    let res = http#get(a:url)
  endtry
  return res
endfunction
"
"
"
call s:set_global_variable('tweetvim_tweet_per_page'  , 20)
call s:set_global_variable('tweetvim_cache_size'      , 10)
call s:set_global_variable('tweetvim_config_dir'      , expand('~/.tweetvim'))
call s:set_global_variable('tweetvim_display_source'  , 0)
call s:set_global_variable('tweetvim_display_time'    , 1)
call s:set_global_variable('tweetvim_log'             , 0)
call s:set_global_variable('tweetvim_open_buffer_cmd' , 'edit!')
call s:set_global_variable('tweetvim_display_separator', 1)


if !isdirectory(g:tweetvim_config_dir)
  call mkdir(g:tweetvim_config_dir, 'p')
endif
"
"
"
command! TweetVimAccessToken  :call tweetvim#access_token()
"
command! TweetVimHomeTimeline :call tweetvim#timeline('home_timeline')
"
command! TweetVimMentions     :call tweetvim#timeline('mentions')
"
command! -nargs=1 -complete=custom,tweetvim#complete_list TweetVimListStatuses :call tweetvim#timeline('list_statuses', tweetvim#verify_credentials().screen_name, <f-args>)
"
command! -nargs=1 -complete=custom,tweetvim#complete_screen_name TweetVimUserTimeline :call tweetvim#timeline('user_timeline', <f-args>)
"
command! -nargs=1 -complete=custom,tweetvim#complete_search TweetVimSearch :call tweetvim#timeline('search', <f-args>)
" tweet with say buffer
command! TweetVimSay :call tweetvim#say#open()
" tweet with command line
command! -nargs=? TweetVimCommandSay :call tweetvim#say#command(<f-args>)
" tweet current line
command! TweetVimCurrentLineSay :call tweetvim#say#current_line()



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
nnoremap <silent> <Plug>(tweetvim_action_search)          :<C-u>call tweetvim#action('search')<CR>
nnoremap <silent> <Plug>(tweetvim_action_remove_status)   :<C-u>call tweetvim#action('remove_status')<CR>
nnoremap <silent> <Plug>(tweetvim_action_expand_url)      :<C-u>call tweetvim#action('expand_url')<CR>


let g:loaded_tweetvim = 1

let &cpo = s:save_cpo
unlet s:save_cpo
