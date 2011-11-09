"
"
"
command! TweetVimAccessToken  :call tweetvim#access_token()
command! TweetVimHomeTimeline :call tweetvim#timeline('home_timeline')
command! TweetVimMentions     :call tweetvim#timeline('mentions')
command! -nargs=+ TweetVimListStatuses :call tweetvim#timeline('list_statuses', <f-args>)


command!          HomeTimeline :call tweetvim#timeline('home_timeline')
command!          Mentions     :call tweetvim#timeline('mentions')
command! -nargs=+ ListStatuses :call tweetvim#timeline('list_statuses', <f-args>)
command! -nargs=1 UserTimeline :call tweetvim#timeline('user_timeline', <f-args>)
command! -nargs=1 Favorites    :call tweetvim#timeline('favorites'    , <f-args>)

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
  nnoremap <silent> <buffer> <CR>             :call tweetvim#action_enter()<CR>
  nnoremap <silent> <buffer> <Leader>r        :call tweetvim#action_reply()<CR>
  nnoremap <silent> <buffer> <Leader><Leader> :call tweetvim#reload()<CR>
endfunction
