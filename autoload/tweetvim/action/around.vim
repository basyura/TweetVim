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
        \ 'max_id'      : a:tweet.id_str,
        \ }])
  let after = tweetvim#request("user_timeline", [a:tweet.user.screen_name, {
        \ 'since_id'      : a:tweet.id_str,
        \ }])

  let tweets = after + before

  call tweetvim#buffer#load(
        \ 'around_tweets',
        \ [],
        \ 'around_tweets', 
        \ tweets,
        \ {})

  call cursor(1,1)
  call search(a:tweet.text)
endfunction
