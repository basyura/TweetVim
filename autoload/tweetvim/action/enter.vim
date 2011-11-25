"
"
"
function! tweetvim#action#enter#define()
  return {
        \ 'description'      : 'open tweet with browser',
        \ 'source__is__list' : 0,
        \ }
endfunction
"
"
"
function! tweetvim#action#enter#execute()
  let matched = matchlist(expand('<cWORD>') , 'https\?://[0-9A-Za-z_#?~=\-+%\.\/:]\+')
  if len(matched) != 0
    execute "OpenBrowser " . matched[0]
    return
  endif
endfunction
