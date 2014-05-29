" syntax for tweetvim_say
"
if exists('b:current_syntax') || !exists('&regexpengine') || &regexpengine == 1
  finish
endif

execute 'syntax match tweetvim_say_mention  "' . escape(tweetvim#tweet#mention_pattern(), '"') . '"'
execute 'syntax match tweetvim_say_link     "' . escape(tweetvim#tweet#url_pattern(),     '"') . '"'
execute 'syntax match tweetvim_say_hash_tag "' . escape(tweetvim#tweet#hashtag_pattern(), '"') . '"'

if get(g:, 'tweetvim_original_hi', 0)

  highlight default tweetvim_say_mention  guifg=#bde682
  highlight default tweetvim_say_link     guifg=#80a0ff
  highlight default tweetvim_say_hash_tag guifg=yellow

else

  highlight default link tweetvim_say_mention  String
  highlight default link tweetvim_say_link     Underlined
  highlight default link tweetvim_say_hash_tag Constant

endif

let b:current_syntax = 'tweetvim_say'
