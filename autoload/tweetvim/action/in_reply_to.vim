"
"
"
function! tweetvim#action#in_reply_to#execute(tweet)
  let tweet = a:tweet
  let list  = []
  let guard = 0
  while 1
    call add(list, tweet)
    let id = tweet.in_reply_to_status_id_str
    if id == ''
      break
    endif
    redraw
    echo 'get ... ' . id
    let tweet = tweetvim#request('show', [id])
    let guard += 1
    if guard > 10
      echohl ErrorMsg | echo 'count over' | echohl None
      break
    endif
  endwhile
  
  call tweetvim#buffer#load(
        \ 'in_reply_to', [], 'in reply to', list, 
        \ {'buf_name' : '[tweetvim - in_reply_to]', 'split' : 1 })
endfunction
