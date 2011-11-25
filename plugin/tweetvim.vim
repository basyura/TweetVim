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
  nnoremap <silent> <buffer> <CR>             :call tweetvim#action#enter()<CR>
  nnoremap <silent> <buffer> <Leader>r        :call tweetvim#action#reply()<CR>
  nnoremap <silent> <buffer> <Leader>i        :call tweetvim#action#in_reply_to()<CR>
  nnoremap <silent> <buffer> <Leader>u        :call tweetvim#action#user_timeline()<CR>
  nnoremap <silent> <buffer> <Leader>f        :call tweetvim#action#favorite()<CR>
  nnoremap <silent> <buffer> <Leader><leader>r :call tweetvim#action#retweet()<CR>
  nnoremap <silent> <buffer> <Leader><leader>q :call tweetvim#action#qt()<CR>
  nnoremap <silent> <buffer> <Leader><Leader> :call tweetvim#action#reload()<CR>
endfunction


let g:loaded_tweetvim = 1

let &cpo = s:save_cpo
unlet s:save_cpo
