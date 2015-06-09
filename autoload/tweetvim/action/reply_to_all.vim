"
"
"
function! tweetvim#action#reply_to_all#define()
  return {
        \ 'description' : 'reply_to_all',
        \ }
endfunction
"
"
"
function! tweetvim#action#reply_to_all#execute(tweet)
  let param = {'in_reply_to_status_id' : a:tweet.id_str}
  let itr = 1
  let receivers = ['@' . a:tweet.user.screen_name]
  let screen_name = matchstr(a:tweet.text,'\(@\w\+\)',0,itr)
  while screen_name != ''
    let itr += 1
    if screen_name != '@' . tweetvim#account#current().screen_name
        \ && index(receivers, screen_name) == -1
      let receivers += [screen_name]
    endif
    let screen_name = matchstr(a:tweet.text,'\(@\w\+\)',0,itr)
  endwhile
  call tweetvim#say#open(join(receivers, ' ') . ' ', param)
endfunction
