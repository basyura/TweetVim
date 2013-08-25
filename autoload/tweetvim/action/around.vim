"
"
"
function! tweetvim#action#around#define()
  return {
        \ 'description' : 'around_tweets',
        \ }
endfunction

"
"
function! tweetvim#action#around#execute(tweet)

  let before = tweetvim#request("user_timeline", [a:tweet.user.screen_name, {
                  \ 'max_id' : a:tweet.id_str,
                  \ 'count'  : 20,
                  \ }])
        
  let id_str = a:tweet.id_str
  let cnt    = 10000
  while 1
    let id_str = s:add(id_str, cnt)
    let after = tweetvim#request("user_timeline", [a:tweet.user.screen_name, {
                  \ 'max_id' : id_str,
                  \ 'count'  : 50,
                  \ }])
    let after  = filter(after, 'v:val.id_str > a:tweet.id_str')
    " todo: any pattern exists.
    "       get 20 tweets but not contained a:tweet
    "           case 1. got after next tweet's
    "           case 2. long term between from a:tweet to next tweet
    if len(after) >= 10 || len(after) == 0 || after[-1].id_str >= a:tweet.id_str
      break
    endif
    redraw
    echo 'get ' . id_str . ' ... ctr-c to break.'
    let cnt = cnt * 2
    "echo 'search - ' . after[0].id_str . ' 〜' . after[-1].id_str . ' <= ' . a:tweet.id_str . ' - ' . id_str
  endwhile


  let tweets = after + before

  call tweetvim#buffer#load(
        \ 'around_tweets',
        \ [],
        \ 'around_tweets', 
        \ tweets,
        \ {})

  call cursor(1,1)
  call search(split(a:tweet.text, '\n')[0])
  
  exec "syn match tweetvim_around_search '" . split(a:tweet.text, '\n')[0] . "'"
endfunction

" add num to str which over number range.
" and return str value
function! s:add(id_str, num)
  let list  = split(a:id_str, '.\{8}\z\s')
  let value = string(str2nr(list[-3]) + a:num)
  for v in list[1:]
    let value .= v
  endfor

  return value
endfunction
