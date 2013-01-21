"
"
"
function! tweetvim#action#page_next#define()
  return {
        \ 'description'      : 'load next page',
        \ 'source__is__list' : 0,
        \ 'need_tweet'       : 0,
        \ }
endfunction
"
"
"
function! tweetvim#action#page_next#execute(tweet, ...)
  let next = a:0 ? a:1 : 1

  try
    let tweetvim_args = deepcopy(b:tweetvim_args)
    if empty(tweetvim_args)
      call add(tweetvim_args, {})
    endif
    let param = tweetvim_args[-1]
    if type(param) != 4
      unlet param
      let param = {}
      call add(tweetvim_args, param)
    endif
    " next page no
    let page = get(param, 'page', 1) + next
    " check no
    if page < 1
      echohl ErrorMsg | echo 'no page' | echohl None
      return
    endif
    let param.page = page
    let b:tweetvim_args = tweetvim_args

    "TODO
    let _ = has_key(param, 'max_id')   ? remove(param, 'max_id')   : ''
    let _ = has_key(param, 'since_id') ? remove(param, 'since_id') : ''

    if b:tweetvim_method == 'search'
      if next == 1
        let param.max_id   = b:tweetvim_status_cache[max(keys(b:tweetvim_status_cache))].id_str
      else
        let param.since_id = b:tweetvim_status_cache[min(keys(b:tweetvim_status_cache))].id_str
      endif
    endif
    let ret = call('tweetvim#timeline', [b:tweetvim_method] + tweetvim_args)
  catch
    echo v:exception
    echohl ErrorMsg | echo 'can not load next page' | echohl None
  endtry
endfunction
