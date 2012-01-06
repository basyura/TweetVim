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
  let text  = ' QT @' . a:tweet.user.screen_name . ':' 
                   \ . tweetvim#util#unescape(a:tweet.text)
  let param = {'in_reply_to_status_id' : a:tweet.id_str}
  call tweetvim#say#open(text, param)
  call cursor(1,1)
endfunction
