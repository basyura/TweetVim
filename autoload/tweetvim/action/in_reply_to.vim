"
"
"
function! tweetvim#action#in_reply_to#define()
  return {
        \ 'description' : 'show conversation',
        \ }
endfunction
"
"
"
function! tweetvim#action#in_reply_to#execute(tweet)
  let tweet = a:tweet
  let list  = []
  let guard = 0
  while 1
    call add(list, tweet)
    if has_key(tweet, 'retweeted_status')
      let id = get(tweet.retweeted_status, 'id_str', '')
    else
      let id = get(tweet, 'in_reply_to_status_id_str', '')
    endif
    if id == ''
      break
    endif
    redraw
    echo 'get ... ' . id
    let tweet = tweetvim#request('show', [id])
    if has_key(tweet, 'errors')
      echohl ErrorMsg | echo tweet.errors[0].message | echohl None
      break
    endif

    let guard += 1
    if guard > 10
      echohl ErrorMsg | echo 'count over' | echohl None
      break
    endif
  endwhile
  
  " TODO:
  let bufno = get(b:, 'tweetvim_bufno', 0)
  if bufno < -1
    call tweetvim#buffer#truncate_backup(bufno)
  endif
  
  call tweetvim#buffer#load('in_reply_to', [], 'in reply to', list)
endfunction
