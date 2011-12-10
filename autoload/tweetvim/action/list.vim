"
"
"
function! tweetvim#action#list#define()
  return {
        \ 'description' : 'add user to list',
        \ }
endfunction
"
"
"
function! tweetvim#action#list#execute(tweet)
  return unite#start([['tweetvim/add_to_list', a:tweet.user.screen_name]])
endfunction
