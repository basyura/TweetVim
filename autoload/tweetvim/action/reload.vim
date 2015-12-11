"
"
"
function! tweetvim#action#reload#define()
  return {
        \ 'description'      : 'reload timeline',
        \ 'source__is__list' : 0,
        \ 'need_tweet'       : 0,
        \ }
endfunction
"
"
"
function! tweetvim#action#reload#execute(tweet)

  if b:tweetvim_method == 'userstream'
    execute 'TweetVimUserStream ' . join(get(b:, 'tweetvim_userstream_track', []), ' ')
    return
  endif

  if b:tweetvim_method == 'around_tweets'
    return
 endif

  try
    let title  = tweetvim#util#padding(getline(1), tweetvim#util#bufwidth() - 10)
    let title .= '[reload]'

    call tweetvim#buffer#replace(1, title)
    redraw
    let ret   = call('tweetvim#timeline', [b:tweetvim_method] + b:tweetvim_args)
    
  catch
    echohl ErrorMsg
    echomsg v:exception . " in " . v:throwpoint
    echomsg 'can not reload'
    echohl None
  endtry
endfunction
