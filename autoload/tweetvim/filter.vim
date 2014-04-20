"
" filter
"
function! tweetvim#filter#execute(tweets)
  let tweets  = a:tweets
  for filter in get(g:, 'tweetvim_filters', ['ngword'])
    let tweets  = function('tweetvim#filter#' . filter . '#execute')(tweets)
  endfor

  let tweets = tweetvim#filter#userstream#execute(tweets)

  return tweets
endfunction
