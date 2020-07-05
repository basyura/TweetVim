" expand tiny urls
"
function! tweetvim#action#expand_url#define()
  return { 'description' : 'expand url' }
endfunction
"
"
"
function! tweetvim#action#expand_url#execute(tweet)
  " expand self text
  let tweet = s:expand(a:tweet)
  " expand quoted text
  if has_key(a:tweet, 'quoted_status')
    let tweet.quoted_status = s:expand(a:tweet.quoted_status)
  endif

  " replace
  let after = tweetvim#buffer#replace(line("."), tweet)
  return after
endfunction

function! s:expand(tweet)
  let tweet = a:tweet
  let text = tweet.text
  " url
  for v in a:tweet.entities.urls
    let text = substitute(text, v.url, v.expanded_url, "")
    "echo "url: " . v.url . " -> " . v.expanded_url
  endfor
  " media
  if has_key(a:tweet.entities, 'media')
    for v in a:tweet.entities.media
      let text = substitute(text, v.url, v.expanded_url, "")
      "echo "media : " . v.url . " -> " . v.expanded_url
    endfor
  endif

  let tweet.text = text

  return tweet
endfunction
