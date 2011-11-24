"
"
"
function! tweetvim#action#reload()
  let ret = call('tweetvim#timeline', [b:tweetvim_method] + b:tweetvim_args)
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
