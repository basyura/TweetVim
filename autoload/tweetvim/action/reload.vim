"
"
"
function! tweetvim#action#reload#define()
  return {
        \ 'description'      : 'reload timeline',
        \ 'source__is__list' : 0,
        \ }
endfunction
"
"
"
function! tweetvim#action#reload#execute(tweet)
  try
    let title = getline(1)
    call tweetvim#buffer#replace(1, title . ' [reload]')
    redraw!
    let ret   = call('tweetvim#timeline', [b:tweetvim_method] + b:tweetvim_args)
    
  catch
    echo v:exception
    echohl ErrorMsg | echo 'can not reload' | echohl None
  endtry
endfunction
