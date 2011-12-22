"=============================================================================
"
" outline for tweetvim
"
" Licensed under the MIT license:
" http://www.opensource.org/licenses/mit-license.php
"
"=============================================================================

function! unite#sources#outline#tweetvim#outline_info()
  return s:outline_info
endfunction

"-----------------------------------------------------------------------------
" Outline Info

let s:outline_info = {
      \ 'heading'  : '^[a-zA-Z0-9_]',
      \ }

function! s:outline_info.create_heading(which, heading_line, matched_line, context)
  return {
        \ 'word'  : unite#util#truncate(a:heading_line, winwidth(0) - 9)
        \ }
endfunction

" vim: filetype=vim
