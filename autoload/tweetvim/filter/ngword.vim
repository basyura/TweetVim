"
" NG word filter
"
function! tweetvim#filter#ngword#execute(tweets)
  if get(g:, 'tweetvim_ng_word', '') == ''
    return a:tweets
  endif

  let ret = []
  for tweet in a:tweets
    if tweet.text =~ g:tweetvim_ng_word
      continue
    endif
    call add(ret, tweet)
  endfor
  return ret
endfunction
