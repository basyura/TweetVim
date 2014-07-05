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
  let text  = has_key(a:tweet, 'retweeted_status') 
               \ ? a:tweet.retweeted_status.text : a:tweet.text
  let opened = 0
  while 1
    let matched = matchlist(text, 'https\?://[0-9A-Za-z_#?~=\-+%\.\/:]\+')
    if len(matched) == 0
      break
    endif
    execute "OpenBrowser " . matched[0]
    let text = substitute(text , matched[0] , "" , "g")
    let opened = 1
  endwhile
endfunction
