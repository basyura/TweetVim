scriptencoding utf-8

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
syntax match tweetvim_screen_name "^\s\=[0-9A-Za-z_]\{-1,} "

syntax match tweetvim_at_screen_name "@[0-9A-Za-z_]\+"

"syntax match tweetvim_link "\<https\?://\S\+"
"syntax match tweetvim_link "\<https\?://[0-9A-Za-z_#?~=\-+%]+"
syntax match tweetvim_link "https\?://[0-9A-Za-z_#?~=\-+%\.\/:]\+"

syntax match tweetvim_hash_tag "[ 　。、]\zs[#＃][^ ].\{-1,}\ze[ \n]"

syntax match tweetvim_separator       "^-\+$"
syntax match tweetvim_separator_title "^\~\+$"

syntax match tweetvim_star " ★ "
syntax match tweetvim_reload "\[reload\]"

syntax match tweetvim_rt_count " [0-9]\+RT"
syntax match tweetvim_rt_over  "'100+'RT"

syn region tweetvim_appendix  start="\[\$" end="\$\]" contains=tweetvim_appendix_value
syn match tweetvim_appendix_value "\[\$\ze.*\ze\$\]"

syntax match tweetvim_appendix "\[\[.\{-1,}\]\]" contains=tweetvim_appendix_block
syntax match tweetvim_appendix_block /\[\[/ contained conceal
syntax match tweetvim_appendix_block /\]\]/ contained conceal

if get(g:, 'tweetvim_original_hi', 0)

  highlight default tweetvim_title            guifg=#bde682
  highlight default tweetvim_status_id        guifg=#444444
  highlight default tweetvim_created_at       guifg=gray
  highlight default tweetvim_screen_name      guifg=#bde682
  highlight default tweetvim_at_screen_name   guifg=#bde682
  highlight default tweetvim_link             guifg=#80a0ff
  highlight default tweetvim_hash_tag         guifg=yellow
  highlight default tweetvim_separator        guifg=#444444
  highlight default tweetvim_separator_title  guifg=#444444
  highlight default tweetvim_star             guifg=yellow
  highlight default tweetvim_reload           guifg=orange
  highlight default tweetvim_rt_count         guifg=orange
  highlight default tweetvim_rt_over          guifg=orange
  highlight default tweetvim_reply            guifg=orange
  highlight default tweetvim_appendix         guifg=#616161

else

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
  hi def link tweetvim_reply           PmenuSel
  hi def link tweetvim_appendix        Comment

endif

let b:current_syntax = 'tweetvim'

