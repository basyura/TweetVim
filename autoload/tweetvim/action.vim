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
"
"
"
function! tweetvim#action#update(text, param)
  return tweetvim#request('update', [a:text, a:param])
endfunction
"
"
"
function! tweetvim#action#user_timeline()
  let tweet = b:tweetvim_status_cache[line('.')]
  call tweetvim#timeline('user_timeline', tweet.user.screen_name)
endfunction
"
"
"
function! tweetvim#action#retweet()
  let tweet = b:tweetvim_status_cache[line('.')]
  echo tweet.user.screen_name . ' ' . tweet.text
  if input('retweet ? [y/n] : ') != 'y'
    return
  endif
  let ret = tweetvim#request('retweet', tweet.id_str)
  redraw
  if has_key(ret, 'errors')
    echohl ErrorMsg | echo ret.errors | echohl None
  else
    echo 'retweeted'
  endif
endfunction
"
"
"
function! tweetvim#action#qt()
  let tweet = b:tweetvim_status_cache[line('.')]
  let text  = ' QT @' . tweet.user.screen_name . ':' . tweet.text
  let param = {'in_reply_to_status_id' : tweet.id_str}
  call tweetvim#say#open(text, param)
  execute "normal 0"
endfunction
