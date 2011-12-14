"
"
"
function! tweetvim#action#user_timeline#define()
  return {
        \ 'description' : 'show user timeline',
        \ }
endfunction
"
"
"
function! tweetvim#action#user_timeline#execute(tweet)
  let screen_name = a:tweet.user.screen_name
  let matched = matchlist(expand('<cWORD>') , '@\zs[0-9A-Za-z_]\+\ze')
  if len(matched) != 0
    let screen_name = matched[0]
  endif
  "call tweetvim#timeline('user_timeline', screen_name, {'opt' : {'user_detail' : 1}})
  call tweetvim#timeline('user_timeline', screen_name)
endfunction
