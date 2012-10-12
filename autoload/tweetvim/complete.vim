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
  let list = tweetvim#cache#get('screen_name')
  let list = extend(list, tweetvim#cache#get('hash_tag'))
  let list = tweetvim#util#uniq(list)
  return join(list, "\n")
endfunction
"
"
"
function! tweetvim#complete#list(argLead, cmdLine, cursorPos)
  return join(map(tweetvim#account#current().lists, 'v:val.name'), "\n")
endfunction
