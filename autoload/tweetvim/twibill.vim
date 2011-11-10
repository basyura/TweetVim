"
"
"
function! tweetvim#twibill#new(config)
  let twibill = twibill#new(a:config)
  "
  " @override
  "
  function! twibill.get(url, ctx, param)

    let param = a:param

    if has_key(self, 'cache_since_id_' . a:url)
      let param.since_id = self['cache_since_id_' . a:url]
    endif

    let res    = oauth#get(a:url, a:ctx, {}, a:param)
    let tweets = json#decode(res.content)
    if self.config.cache && type(tweets) == 3
      let cache = tweets + get(self, 'cache_tweets_' . a:url, []) 
      if empty(tweets)
        return [[],cache]
      else
        let self['cache_since_id_' . a:url] = tweets[0].id_str
        let self['cache_tweets_'   . a:url] = cache
        return [cache[:len(tweets) - 1],cache[len(tweets):]]
      endif
    endif
    return tweets
  endfunction

  return twibill
endfunction
