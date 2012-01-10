"
"
"
function! tweetvim#action#enter#define()
  return {
        \ 'description'      : 'open tweet with browser',
        \ 'source__is__list' : 0,
        \ 'need_tweet'       : 0,
        \ }
endfunction
"
"
"
function! tweetvim#action#enter#execute(tweet)
  let word = expand('<cWORD>')
  let matched = matchlist(word, 'https\?://[0-9A-Za-z_#?~=\-+%\.\/:]\+')
  if len(matched) != 0
    execute "OpenBrowser " . matched[0]
    return
  endif

  let matched = matchlist(word, '^\#.*')
  if len(matched) != 0
     call tweetvim#timeline('search', word)
     return
  endif
endfunction
