"
"
"
function! tweetvim#action#reply#define()
  return {
        \ 'description' : 'reply',
        \ }
endfunction
"
"
"
function! tweetvim#action#reply#execute(tweet)
  let param = {'in_reply_to_status_id' : a:tweet.id_str}
  call tweetvim#say#open('@' . a:tweet.user.screen_name . ' ', param)
endfunction
