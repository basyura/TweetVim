if exists('g:loaded_tweetvim')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim
"
"
"
command! TweetVimAccessToken  :call tweetvim#access_token()
command! TweetVimHomeTimeline :call tweetvim#timeline('home_timeline')
command! TweetVimMentions     :call tweetvim#timeline('mentions')
command! -nargs=+ TweetVimListStatuses :call tweetvim#timeline('list_statuses', <f-args>)
command! TweetVimSay          :call tweetvim#say#open()


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

  nnoremap <silent> <buffer> a :call unite#sources#tweetvim_action#start()<CR>
  nnoremap <silent> <buffer> t :call unite#sources#tweetvim_timeline#start()<CR>
endfunction


let g:loaded_tweetvim = 1

let &cpo = s:save_cpo
unlet s:save_cpo
