"
"
"
function! tweetvim#action#reload()
  try
    let ret = call('tweetvim#timeline', [b:tweetvim_method] + b:tweetvim_args)
  catch
    echohl ErrorMsg | echo 'can not reload' | echohl None
  endtry
endfunction
"
"
"
function! tweetvim#action#enter()
  let matched = matchlist(expand('<cWORD>') , 'https\?://[0-9A-Za-z_#?~=\-+%\.\/:]\+')
  if len(matched) != 0
    execute "OpenBrowser " . matched[0]
    return
  endif
endfunction
"
"
"
function! tweetvim#action#reply()
  let line = line('.')
  if !has_key(b:tweetvim_status_cache, line)
    return
  endif
  let tweet = b:tweetvim_status_cache[line]
  let param = {'in_reply_to_status_id' : tweet.id_str}
  call tweetvim#say#open('@' . tweet.user.screen_name . ' ', param)
endfunction
"
"
"
function! tweetvim#action#in_reply_to()
  let tweet = b:tweetvim_status_cache[line('.')]

  let list = []
  while 1
    call add(list, tweet)
    let id = tweet.in_reply_to_status_id_str
    if id == ''
      break
    endif
    let tweet = tweetvim#get_tweets('show', [id])
  endwhile
  
  call tweetvim#load_timeline(
        \ 'in_reply_to', [], 'in reply to', list, 
        \ {'buf_name' : '[tweetvim - in_reply_to]', 'split' : 1 })
endfunction

