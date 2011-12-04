if exists('g:loaded_tweetvim')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim
"
"
let g:tweetvim_cache_size = 10
let g:tweetvim_config_dir = expand('~/.tweetvim')

if !isdirectory(g:tweetvim_config_dir)
  call mkdir(g:tweetvim_config_dir, 'p')
endif
"
"
"
command! TweetVimAccessToken  :call tweetvim#access_token()
command! TweetVimHomeTimeline :call tweetvim#timeline('home_timeline')
command! TweetVimMentions     :call tweetvim#timeline('mentions')
command! -nargs=1 -complete=custom,tweetvim#complete_list TweetVimListStatuses :call tweetvim#timeline('list_statuses', tweetvim#verify_credentials().screen_name, <f-args>)
command! -nargs=1 -complete=custom,tweetvim#complete_screen_name TweetVimUserTimeline :call tweetvim#timeline('user_timeline', <f-args>)
command! TweetVimSay          :call tweetvim#say#open()



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

  let shorturl = bitly#shorten(url).url
  let content = http#get(url).content
  let charset = matchstr(content , 'charset=\zs.\{-}\ze".\{-}>')
  let title = iconv(matchstr(content , '<title>\zs.\{-}\ze</title>') ,
        \ charset , 'utf-8')
  let shorturl = '> ' . title . ' ' . shorturl
  execute "normal! a".shorturl."\<esc>"
endfunction


"command!          HomeTimeline :call tweetvim#timeline('home_timeline')
"command!          Mentions     :call tweetvim#timeline('mentions')
"command! -nargs=+ ListStatuses :call tweetvim#timeline('list_statuses', <f-args>)
"command! -nargs=1 UserTimeline :call tweetvim#timeline('user_timeline', <f-args>)
"command! -nargs=1 Favorites    :call tweetvim#timeline('favorites'    , <f-args>)
"command! -nargs=1 SearchTweets :call tweetvim#timeline('search'       , <f-args>)
"

nnoremap <silent> <Plug>(tweetvim_action_enter)           :<C-u>call tweetvim#action('enter')<CR>
nnoremap <silent> <Plug>(tweetvim_action_reply)           :<C-u>call tweetvim#action('reply')<CR>
nnoremap <silent> <Plug>(tweetvim_action_in_reply_to)     :<C-u>call tweetvim#action('in_reply_to')<CR>
nnoremap <silent> <Plug>(tweetvim_action_user_timeline)   :<C-u>call tweetvim#action('user_timeline')<CR>
nnoremap <silent> <Plug>(tweetvim_action_favorite)        :<C-u>call tweetvim#action('favorite')<CR>
nnoremap <silent> <Plug>(tweetvim_action_remove_favorite) :<C-U>call tweetvim#action('remove_favoite')<CR>
nnoremap <silent> <Plug>(tweetvim_action_retweet)         :<C-u>call tweetvim#action('retweet')<CR>
nnoremap <silent> <Plug>(tweetvim_action_qt)              :<C-u>call tweetvim#action('qt')<CR>
nnoremap <silent> <Plug>(tweetvim_action_reload)          :<C-u>call tweetvim#action('reload')<CR>
nnoremap <silent> <Plug>(tweetvim_action_page_next)       :<C-u>call tweetvim#action('page_next')<CR>
nnoremap <silent> <Plug>(tweetvim_action_page_previous)   :<C-u>call tweetvim#action('page_previous')<CR>

nnoremap <silent> <Plug>(tweetvim_buffer_previous)        :<C-u>call tweetvim#buffer#previous()<CR>
nnoremap <silent> <Plug>(tweetvim_buffer_next)            :<C-u>call tweetvim#buffer#next()<CR>
"
"
"
augroup tweetvim
  autocmd!
  autocmd FileType tweetvim call s:tweetvim_settings()
augroup END  
"
"
"
function! s:tweetvim_settings()
  nmap <silent> <buffer> <CR>       <Plug>(tweetvim_action_enter)
  nmap <silent> <buffer> r  <Plug>(tweetvim_action_reply)
  nmap <silent> <buffer> i  <Plug>(tweetvim_action_in_reply_to)
  nmap <silent> <buffer> u  <Plug>(tweetvim_action_user_timeline)
  nmap <silent> <buffer> <leader>f  <Plug>(tweetvim_action_favorite)
  nmap <silent> <buffer> <leader>uf <Plug>(tweetvim_action_remove_favorite)
  nmap <silent> <buffer> <leader>r  <Plug>(tweetvim_action_retweet)
  nmap <silent> <buffer> <leader>q  <Plug>(tweetvim_action_qt)
  nmap <silent> <buffer> <Leader><Leader>  <Plug>(tweetvim_action_reload)

  nmap <silent> <buffer> nn  <Plug>(tweetvim_action_page_next)
  nmap <silent> <buffer> pp  <Plug>(tweetvim_action_page_previous)

  nmap <silent> <buffer> H  <Plug>(tweetvim_buffer_previous)
  nmap <silent> <buffer> L  <Plug>(tweetvim_buffer_next)

  nnoremap <silent> <buffer> a :call unite#sources#tweetvim_action#start()<CR>
  nnoremap <silent> <buffer> t :call unite#sources#tweetvim_timeline#start()<CR>
endfunction


let g:loaded_tweetvim = 1

let &cpo = s:save_cpo
unlet s:save_cpo
