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
  let matched_str = ''
  let itr = 1
  let reply_text = ''
  let matched_str = matchstr(a:tweet.text,'\(@\w\+\)',0,itr)
  while matched_str != ''
    let itr += 1
    if (matched_str != '@' . tweetvim#account#current().screen_name)
      let reply_text .= matched_str . ' '
    endif
    let matched_str = matchstr(a:tweet.text,'\(@\w\+\)',0,itr)
  endwhile
  call tweetvim#say#open('@' . a:tweet.user.screen_name . ' ' . reply_text, param)
endfunction
