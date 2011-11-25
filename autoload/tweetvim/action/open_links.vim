"
"
"
function! tweetvim#action#open_links#define()
  return {
        \ 'description' : 'open links in tweet',
        \ }
endfunction
"
"
"
function! tweetvim#action#open_links#execute(tweet)
  let text  = a:tweet.text
  while 1
    let matched = matchlist(text, 'https\?://[0-9A-Za-z_#?~=\-+%\.\/:]\+')
    if len(matched) == 0
      break
    endif
    execute "OpenBrowser " . matched[0]
    let text = substitute(text , matched[0] , "" , "g")
  endwhile
endfunction
