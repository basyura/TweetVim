"
"
"
function! tweetvim#action#qt#define()
  return {
        \ 'description' : 'quote tweet',
        \ }
endfunction
"
"
"
function! tweetvim#action#qt#execute(tweet)
  let text  = ' https://twitter.com/' . a:tweet.user.screen_name . '/status/' . a:tweet.id_str
  let param = {'in_reply_to_status_id' : a:tweet.id_str}
  call tweetvim#say#open(text, param)
  call cursor(1,1)
endfunction
