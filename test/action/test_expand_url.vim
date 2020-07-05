"
" test for expand_url action
"
let s:fixture_dir = expand('<sfile>:p:h') . '/../fixture/'
let s:suite = themis#suite('test expand url')
let s:assert = themis#helper('assert')

let g:tweetvim_display_time = 0

function s:read_tweet(file_name)
   let text = join(readfile(s:fixture_dir . '/' . a:file_name) , "\n")
   return json_decode(text)
endfunction

function! s:suite.simple1()
  let tweet = s:read_tweet("tweet1.json")
  let actual = tweetvim#action#expand_url#execute(tweet)

  let expected = tweetvim#util#padding(tweet.user.screen_name, 15) . ' : ' .
                  \ "test https://www.google.com/"

  call s:assert.equals(actual, expected)
endfunction

function! s:suite.simple2()
  let tweet = s:read_tweet("tweet2.json")
  let actual = tweetvim#action#expand_url#execute(tweet)

  let expected = tweetvim#util#padding(tweet.user.screen_name, 15) . ' : ' .
                  \ "test2\n                                 https://www.google.com/"

  call s:assert.equals(actual, expected)
endfunction

"function! s:suite.include_quoted_status()
  "let tweet = s:read_tweet("tweet2.json")
  "let expected = tweetvim#util#padding(tweet.user.screen_name, 15) . ' : ' . 
                  "\ "テキストテキストテキスト https://citemaster.net/get/3c501aaa-39d5-11e4-9cb6-00163e009cc7/R8.pdf https://twitter.com/User00001/status/99887766554433221100 30RT"
  "let actual = tweetvim#action#expand_url#execute(tweet)
  "call s:assert.equals(expected, actual)
"endfunction
