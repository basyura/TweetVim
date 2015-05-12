"
"
"
function! tweetvim#complete#screen_name(argLead, cmdLine, cursorPos)
  return join(sort(tweetvim#cache#get('screen_name')), "\n")
endfunction
"
"
"
function! tweetvim#complete#account(arglead, ...)
  return join(sort(map(tweetvim#account#users(), 'v:val.screen_name')), "\n")
endfunction
"
"
"
function! tweetvim#complete#search(argLead, cmdLine, cursorPos)
  let list = tweetvim#cache#get('screen_name')
  let list = extend(list, tweetvim#cache#get('hash_tag'))
  let list = tweetvim#util#uniq(list)
  return join(sort(list), "\n")
endfunction
"
"
"
function! tweetvim#complete#list(argLead, cmdLine, cursorPos)
  let screen_name = tweetvim#account#current().screen_name
  let slugs = []
  for list in tweetvim#account#current().get_lists()
    if list.user.screen_name == screen_name
      call add(slugs, list.slug)
    endif
  endfor

  return join(sort(slugs), "\n")
endfunction
