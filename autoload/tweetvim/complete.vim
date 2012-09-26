"
"
"
function! tweetvim#complete#screen_name(argLead, cmdLine, cursorPos)
  return join(tweetvim#cache#get('screen_name'), "\n")
endfunction
"
"
"
function! tweetvim#complete#account(arglead, ...)
  return join(map(tweetvim#account#users(), 'v:val.screen_name'), "\n")
endfunction
"
"
"
function! tweetvim#complete#search(argLead, cmdLine, cursorPos)
  let name = tweetvim#cache#get('screen_name')
  let tag  = tweetvim#cache#get('hash_tag')
  call extend(name, tag)
  return join(name, "\n")
endfunction
"
"
"
function! tweetvim#complete#list(argLead, cmdLine, cursorPos)
  return join(map(tweetvim#account#current().lists, 'v:val.name'), "\n")
endfunction
