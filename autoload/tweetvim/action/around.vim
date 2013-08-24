"
"
"
function! tweetvim#action#around#define()
  return {
        \ 'description' : 'around_tweets',
        \ }
endfunction
"
"
"
function! tweetvim#action#around#execute(tweet)
  let before = tweetvim#request("user_timeline", [a:tweet.user.screen_name, {
        \ 'max_id'   : a:tweet.id_str,
        \ 'count'    : 20,
        \ }])
  let after = tweetvim#request("user_timeline", [a:tweet.user.screen_name, {
        \ 'since_id' : a:tweet.id_str,
        \ 'count'    : 200,
        \ }])

  let tweets = after + before

  call tweetvim#buffer#load(
        \ 'around_tweets',
        \ [],
        \ 'around_tweets', 
        \ tweets,
        \ {})

  call cursor(1,1)
  call search(split(a:tweet.text, '\n')[0])
  
  exec "syn match tweetvim_around_search '" . split(a:tweet.text, '\n')[0] . "'"
endfunction
