"
" userstream track filter
"
function! tweetvim#filter#userstream#execute(tweets)
  if get(b:, 'tweetvim_method', '') != 'userstream'
    return a:tweets
  endif

  if !get(b:, 'tweetvim_userstream_bang', 0)
    return a:tweets
  endif

  let ret = []
  for tweet in a:tweets
    for word in b:tweetvim_userstream_track
      if has_key(tweet, 'text') && tweet.text =~? word
        call add(ret, tweet)
      endif
    endfor
  endfor
  return ret
endfunction
