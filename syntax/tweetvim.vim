
" syntax for tweetvim
"
if exists('b:current_syntax')
  finish
endif

setlocal conceallevel=2
setlocal concealcursor=nc

syntax match tweetvim_title "^\[.*" contains=tweetvim_reload

syntax match tweetvim_status_id "\[\d\{-1,}\]$"
"syntax match tweetvim_created_at "- .\{-1,} \[" 
"
syntax match tweetvim_screen_name "^[0-9A-Za-z_]\{-1,} "

syntax match tweetvim_at_screen_name "@[0-9A-Za-z_]\+"

"syntax match tweetvim_link "\<https\?://\S\+"
"syntax match tweetvim_link "\<https\?://[0-9A-Za-z_#?~=\-+%]+"
syntax match tweetvim_link "https\?://[0-9A-Za-z_#?~=\-+%\.\/:]\+"

syntax match tweetvim_hash_tag "[ 　。、]\zs[#＃][^ ].\{-1,}\ze[ \n]"

syntax match tweetvim_separator       "^-\+$"
syntax match tweetvim_separator_title "^\~\+$"
syntax match tweetvim_new_separator   "^\s\+$"

syntax match tweetvim_star " ★ "
syntax match tweetvim_reload "\[reload\]"

syntax match tweetvim_rt_count " [0-9]\+RT"
syntax match tweetvim_rt_over  "'100+'RT"

syn region tweetvim_appendix  start="\[\$" end="\$\]" contains=tweetvim_appendix_value
syn match tweetvim_appendix_value "\[\$\ze.*\ze\$\]"

syntax match tweetvim_appendix "\[\[.\{-1,}\]\]" contains=tweetvim_appendix_block
syntax match tweetvim_appendix_block /\[\[/ contained conceal
syntax match tweetvim_appendix_block /\]\]/ contained conceal


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

hi def link tweetvim_title           Title
hi def link tweetvim_status_id       Special
hi def link tweetvim_created_at      NonText
hi def link tweetvim_screen_name     String
hi def link tweetvim_at_screen_name  String
hi def link tweetvim_link            Underlined
hi def link tweetvim_hash_tag        Constant
hi def link tweetvim_separator       Ignore
hi def link tweetvim_separator_title Ignore
hi def link tweetvim_new_separator   Conditional
hi def link tweetvim_star            Conditional
hi def link tweetvim_reload          Constant
hi def link tweetvim_rt_count        Question
hi def link tweetvim_rt_over         Question
hi def link tweetvim_reply           Delimiter
hi def link tweetvim_appendix        Comment

let b:current_syntax = 'tweetvim'

