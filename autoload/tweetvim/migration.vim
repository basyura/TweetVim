"
"
"
function! tweetvim#migration#execute()
  let from    = g:tweetvim_config_dir . '/token'
  let tokens  = readfile(from)


  let twibill = twibill#new({
    \ 'consumer_key'        : '8hht6fAi3wU47cwql0Cbkg',
    \ 'consumer_secret'     : 'sbmqcNqlfwpBPk8QYdjwlaj0PIZFlbEXvSxxNrJDcAU',
    \ 'access_token'        : tokens[0] ,
    \ 'access_token_secret' : tokens[1] ,
    \ })

  let credentials = twibill.verify_credentials()
  let to_dir = g:tweetvim_config_dir . '/accounts/' . credentials.screen_name

  call mkdir(to_dir, 'p')
  call rename(from, to_dir . '/token')

  let acMgr = tweetvim#account#new_manager()
  call acMgr.add(credentials)

  echomsg 'tweetvim - migrated token file'
endfunction
