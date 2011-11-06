"
"
"
command! TweetVimAccessToken  :call tweetvim#access_token()
command! TweetVimHomeTimeline :call tweetvim#timeline('home_timeline')
command! TweetVimMentions     :call tweetvim#timeline('mentions')
command! -nargs=+ TweetVimListStatuses :call tweetvim#timeline('list_statuses', <f-args>)
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
