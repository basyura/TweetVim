"
"
"
function! tweetvim#twibill#new(config)
  let twibill = twibill#new(a:config)
  "
  " @override
  "
  "function! twibill.get(url, param)

    "let param = a:param

    "if has_key(self, 'cache_since_id_' . a:url)
      "let param.since_id = self['cache_since_id_' . a:url]
    "endif

    "let res    = twibill#oauth#get(a:url, self.ctx(), {}, a:param)
    "" for debug
    "if g:tweetvim_log
      "call tweetvim#log('twibill#get url    : ' . a:url)
      "call tweetvim#log('twibill#get param  : ', param)
      "call tweetvim#log('twibill#get header : ', res.header)
    "endif
    ""
    "let tweets = twibill#json#decode(res.content)

    "if a:url =~ "search.json"
      "let results = tweets['results']
      "unlet tweets
      "let tweets = results
      "for tweet in tweets
        "let tweet.user = {'screen_name' : tweet.from_user}
        "let tweet.favorited = 0
        "let tweet.is_new    = 1
      "endfor
      "return tweets
    "endif

    "return tweets

    "if self.config.cache && type(tweets) == 3
      "let cache = tweets + get(self, 'cache_tweets_' . a:url, []) 
      "if empty(tweets)
        "return cache
      "else
        "let self['cache_since_id_' . a:url] = tweets[0].id_str
        "let self['cache_tweets_'   . a:url] = cache

        "let copied = deepcopy(tweets)
        "for t in copied
          "let t.is_new = 1
        "endfor

        "return copied + cache[len(tweets):]
      "endif
    "endif
    "return tweets
  "endfunction

  return twibill
endfunction
