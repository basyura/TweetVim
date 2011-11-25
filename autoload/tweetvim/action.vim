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
function! tweetvim#action#update(text, param)
  return tweetvim#request('update', [a:text, a:param])
endfunction
