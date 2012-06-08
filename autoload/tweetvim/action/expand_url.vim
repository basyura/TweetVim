
"
"
"
function! tweetvim#action#expand_url#define()
  return {
        \ 'description' : 'expand url' ,
        \ }
endfunction
"
"
"
function! tweetvim#action#expand_url#execute(tweet)
  let untiny_api = 'http://untiny.me/api/1.0/extract?url='
  let pattern    = 'https\?://[0-9A-Za-z_#?~=\-+%\.\/:]\+'

  let text = a:tweet.text

  let list = []

  while 1
    let url = matchstr(text, pattern)
    if url == ''
      break
    endif
    let text = substitute(text, url, "", "")
    call add(list, url)
  endwhile

  let text = a:tweet.text
  for v in list
    let ret  = twibill#http#get(untiny_api . v . '&format=text')
    if ret.content =~ '^error' || ret.content =~ '<response'
      continue
    endif
    let text = substitute(text, v, ret.content, '')
  endfor
  " replace
  let tweet = a:tweet
  let tweet.text = text
  call tweetvim#buffer#replace(line("."), tweet)
endfunction
