
" syntax for tweetvim
"
"if exists('b:current_syntax')
  "finish
"endif

setlocal conceallevel=2
setlocal concealcursor=nc

syntax match tweetvim_status_id "\[\d\{-1,}\]$" 
"syntax match tweetvim_created_at "- .\{-1,} \[" 
"
syntax match tweetvim_screen_name "^[0-9A-Za-z_]\{-1,} "

"syntax match uiki_strong /|[^|]\+|/ contains=uiki_strong_bar
"syntax match uiki_page_block /\[\[/ contained conceal
"syntax match uiki_page_block /\]\]/ contained conceal
"syntax match uiki_strong_bar /|/ contained conceal

"syntax match uiki_link "\<http://\S\+"
"syntax match uiki_link "\<https://\S\+"

"syntax match uiki_title1 "^\* .*"
"syntax match uiki_title2 "\s\* .*"


"highlight default link uiki_page_link Underlined
"highlight default link uiki_page_block Statement

"highlight default link uiki_link Underlined
"highlight uiki_title1 guifg=orange gui=underline
"highlight uiki_title2 guifg=orange

"highlight uiki_strong guifg=#FF80FF

highlight tweetvim_status_id  guifg=gray
highlight tweetvim_created_at guifg=gray
highlight tweetvim_screen_name guifg=orange

let b:current_syntax = 'tweetvim'

