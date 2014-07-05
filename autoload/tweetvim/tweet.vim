let s:save_cpo = &cpo
set cpo&vim

scriptencoding utf-8

let s:TWEET_LIMIT = 140

" Referred the following software to implement this code.  Thanks!
"
" twitter-text-rb
" Copyright 2011 Twitter, Inc.
" https://github.com/twitter/twitter-text-rb

function! s:nr2char(nr)
  if !exists('&regexpengine')
    return a:nr
  else
    return iconv(nr2char(a:nr, 1), 'utf-8', &encoding)
  end
endfunction

" Vim can not treat combining character in character class well.
function! s:is_combining_char(ch)
  return len(split('.' . a:ch, '.\zs')) != 2
endfunction

" XXX: Ignore the combining character
function! s:regex_range(from, ...)
  let from = s:nr2char(a:from)
  if s:is_combining_char(from)
    return ''
  endif
  if !a:0
    return from
  endif

  let to = s:nr2char(a:1)
  return s:is_combining_char(to) ? '' : printf('%s-%s', from, to)
endfunction

let s:UNICODE_SPACES =
\ join(map(
\   range(0x0009, 0x000D) +
\   [0x0020, 0x0085, 0x00A0, 0x1680, 0x180E] +
\   range(0x2000, 0x200A) +
\   [0x2028, 0x2029, 0x202F, 0x205F, 0x3000],
\ 's:nr2char(v:val)'), '')

let s:INVALID_CHARACTERS = join(map([
\   0xFFFE, 0xFEFF, 0xFFFF, 0x202A, 0x202B, 0x202C, 0x202D, 0x202E
\ ], 's:nr2char(v:val)'), '')

let s:LATIN_ACCENTS = join([
\   s:regex_range(0xC0, 0xD6),
\   s:regex_range(0xD8, 0xF6),
\   s:regex_range(0xF8, 0xFF),
\   s:regex_range(0x0100, 0x024F),
\   s:regex_range(0x0253, 0x0254),
\   s:regex_range(0x0256, 0x0257),
\   s:regex_range(0x0259),
\   s:regex_range(0x025B),
\   s:regex_range(0x0263),
\   s:regex_range(0x0268),
\   s:regex_range(0x026F),
\   s:regex_range(0x0272),
\   s:regex_range(0x0289),
\   s:regex_range(0x028B),
\   s:regex_range(0x02BB),
\   s:regex_range(0x0300, 0x036F),
\   s:regex_range(0x1E00, 0x1EFF),
\ ], '')
let s:latin_accents = printf(
\   '[%s]',
\   s:LATIN_ACCENTS
\ )

let s:NON_LATIN_HASHTAG_CHARS = join([
\  s:regex_range(0x0400, 0x04FF),
\  s:regex_range(0x0500, 0x0527),
\  s:regex_range(0x2DE0, 0x2DFF),
\  s:regex_range(0xA640, 0xA69F),
\  s:regex_range(0x0591, 0x05BF),
\  s:regex_range(0x05C1, 0x05C2),
\  s:regex_range(0x05C4, 0x05C5),
\  s:regex_range(0x05C7),
\  s:regex_range(0x05D0, 0x05EA),
\  s:regex_range(0x05F0, 0x05F4),
\  s:regex_range(0xFB12, 0xFB28),
\  s:regex_range(0xFB2A, 0xFB36),
\  s:regex_range(0xFB38, 0xFB3C),
\  s:regex_range(0xFB3E),
\  s:regex_range(0xFB40, 0xFB41),
\  s:regex_range(0xFB43, 0xFB44),
\  s:regex_range(0xFB46, 0xFB4F),
\  s:regex_range(0x0610, 0x061A),
\  s:regex_range(0x0620, 0x065F),
\  s:regex_range(0x066E, 0x06D3),
\  s:regex_range(0x06D5, 0x06DC),
\  s:regex_range(0x06DE, 0x06E8),
\  s:regex_range(0x06EA, 0x06EF),
\  s:regex_range(0x06FA, 0x06FC),
\  s:regex_range(0x06FF),
\  s:regex_range(0x0750, 0x077F),
\  s:regex_range(0x08A0),
\  s:regex_range(0x08A2, 0x08AC),
\  s:regex_range(0x08E4, 0x08FE),
\  s:regex_range(0xFB50, 0xFBB1),
\  s:regex_range(0xFBD3, 0xFD3D),
\  s:regex_range(0xFD50, 0xFD8F),
\  s:regex_range(0xFD92, 0xFDC7),
\  s:regex_range(0xFDF0, 0xFDFB),
\  s:regex_range(0xFE70, 0xFE74),
\  s:regex_range(0xFE76, 0xFEFC),
\  s:regex_range(0x200C, 0x200C),
\  s:regex_range(0x0E01, 0x0E3A),
\  s:regex_range(0x0E40, 0x0E4E),
\  s:regex_range(0x1100, 0x11FF),
\  s:regex_range(0x3130, 0x3185),
\  s:regex_range(0xA960, 0xA97F),
\  s:regex_range(0xAC00, 0xD7AF),
\  s:regex_range(0xD7B0, 0xD7FF),
\  s:regex_range(0xFFA1, 0xFFDC),
\], '')

let s:CJ_HASHTAG_CHARACTERS = join([
\  s:regex_range(0x30A1, 0x30FA), s:regex_range(0x30FC, 0x30FE),
\  s:regex_range(0xFF66, 0xFF9F),
\  s:regex_range(0xFF10, 0xFF19), s:regex_range(0xFF21, 0xFF3A), s:regex_range(0xFF41, 0xFF5A),
\  s:regex_range(0x3041, 0x3096), s:regex_range(0x3099, 0x309E),
\  s:regex_range(0x3400, 0x4DBF),
\  s:regex_range(0x4E00, 0x9FFF),
\  s:regex_range(0x20000, 0x2A6DF),
\  s:regex_range(0x2A700, 0x2B73F),
\  s:regex_range(0x2B740, 0x2B81F),
\  s:regex_range(0x2F800, 0x2FA1F), s:regex_range(0x3003), s:regex_range(0x3005), s:regex_range(0x303B),
\], '')

let s:PUNCTUATION_CHARS = '!"#$%&''()*+,-./:;<=>?@\[\]^_\`{|}~'
let s:SPACE_CHARS = " \t\n\x0B\f\r"
let s:CTRL_CHARS = "\x00-\x1F\x7F"

let s:HASHTAG_ALPHA = printf(
\   '[a-z_%s%s%s]',
\   s:LATIN_ACCENTS,
\   s:NON_LATIN_HASHTAG_CHARS,
\   s:CJ_HASHTAG_CHARACTERS
\ )
let s:HASHTAG_ALPHANUMERIC = printf(
\   '[a-z0-9_%s%s%s]',
\   s:LATIN_ACCENTS,
\   s:NON_LATIN_HASHTAG_CHARS,
\   s:CJ_HASHTAG_CHARACTERS
\ )
let s:HASHTAG_BOUNDARY = printf(
\   '^\|[^&a-z0-9_%s%s%s]',
\   s:LATIN_ACCENTS,
\   s:NON_LATIN_HASHTAG_CHARS,
\   s:CJ_HASHTAG_CHARACTERS
\ )

let s:HASHTAG = printf(
\   '\(%s\)\(#\|＃\)\(%s*%s%s*\)',
\   s:HASHTAG_BOUNDARY,
\   s:HASHTAG_ALPHANUMERIC,
\   s:HASHTAG_ALPHA,
\   s:HASHTAG_ALPHANUMERIC
\ )
let s:valid_hashtag = '\c' . s:HASHTAG
let s:end_hashtag_match = '\%([#＃]\|://\)'

let s:valid_mention_preceding_chars = '\%([^a-zA-Z0-9_!#\$%&*@＠]\|^\|[rR][tT]:?\)'
let s:at_signs = '[@＠]'
let s:valid_mention_or_list = printf(
\   '\(%s\)\(%s\)\([a-zA-Z0-9_]\{1,20}\)\(\/[a-zA-Z][a-zA-Z0-9_\-]\{0,24}\)\?',
\   s:valid_mention_preceding_chars,
\   s:at_signs
\ )
let s:end_mention_match = printf(
\   '\%(%s\|%s\|://\)',
\   s:at_signs,
\   s:latin_accents
\ )

let s:valid_url_preceding_chars = printf(
\   '\%%([^A-Z0-9@＠$#＃%s]\|^\)',
\   s:INVALID_CHARACTERS
\ )

let s:valid_url_without_protocol_preceding_chars = printf(
\   '\%%([^-_.\/A-Z0-9@＠$#＃%s]\|^\)',
\   s:INVALID_CHARACTERS
\ )
let s:invalid_url_without_protocol_preceding_chars = '[-_.\/]$'

let s:DOMAIN_VALID_CHARS = printf(
\   '[^%s%s%s%s%s]',
\   s:PUNCTUATION_CHARS,
\   s:SPACE_CHARS,
\   s:CTRL_CHARS,
\   s:UNICODE_SPACES,
\   s:INVALID_CHARACTERS
\ )
let s:valid_subdomain = printf(
\   '\%%(\%%(%s\%%([_-]\|%s\)*\)\?%s\.\)',
\   s:DOMAIN_VALID_CHARS,
\   s:DOMAIN_VALID_CHARS,
\   s:DOMAIN_VALID_CHARS
\ )
let s:valid_domain_name = printf(
\   '\%%(\%%(%s\%%([-]\|%s\)*\)\?%s\.\)',
\   s:DOMAIN_VALID_CHARS,
\   s:DOMAIN_VALID_CHARS,
\   s:DOMAIN_VALID_CHARS
\ )

let s:valid_gTLD = printf(
\   '\%%(\%%(%s\)\)\%%([^0-9a-z@]\|$\)\@=',
\   join([
\    'academy',
\    'actor',
\    'aero',
\    'agency',
\    'arpa',
\    'asia',
\    'bar',
\    'bargains',
\    'berlin',
\    'best',
\    'bid',
\    'bike',
\    'biz',
\    'blue',
\    'boutique',
\    'build',
\    'builders',
\    'buzz',
\    'cab',
\    'camera',
\    'camp',
\    'cards',
\    'careers',
\    'cat',
\    'catering',
\    'center',
\    'ceo',
\    'cheap',
\    'christmas',
\    'cleaning',
\    'clothing',
\    'club',
\    'codes',
\    'coffee',
\    'com',
\    'community',
\    'company',
\    'computer',
\    'construction',
\    'contractors',
\    'cool',
\    'coop',
\    'cruises',
\    'dance',
\    'dating',
\    'democrat',
\    'diamonds',
\    'directory',
\    'domains',
\    'edu',
\    'education',
\    'email',
\    'enterprises',
\    'equipment',
\    'estate',
\    'events',
\    'expert',
\    'exposed',
\    'farm',
\    'fish',
\    'flights',
\    'florist',
\    'foundation',
\    'futbol',
\    'gallery',
\    'gift',
\    'glass',
\    'gov',
\    'graphics',
\    'guitars',
\    'guru',
\    'holdings',
\    'holiday',
\    'house',
\    'immobilien',
\    'industries',
\    'info',
\    'institute',
\    'int',
\    'international',
\    'jobs',
\    'kaufen',
\    'kim',
\    'kitchen',
\    'kiwi',
\    'koeln',
\    'kred',
\    'land',
\    'lighting',
\    'limo',
\    'link',
\    'luxury',
\    'management',
\    'mango',
\    'marketing',
\    'menu',
\    'mil',
\    'mobi',
\    'moda',
\    'monash',
\    'museum',
\    'nagoya',
\    'name',
\    'net',
\    'neustar',
\    'ninja',
\    'okinawa',
\    'onl',
\    'org',
\    'partners',
\    'parts',
\    'photo',
\    'photography',
\    'photos',
\    'pics',
\    'pink',
\    'plumbing',
\    'post',
\    'pro',
\    'productions',
\    'properties',
\    'pub',
\    'qpon',
\    'recipes',
\    'red',
\    'rentals',
\    'repair',
\    'report',
\    'reviews',
\    'rich',
\    'ruhr',
\    'sexy',
\    'shiksha',
\    'shoes',
\    'singles',
\    'social',
\    'solar',
\    'solutions',
\    'supplies',
\    'supply',
\    'support',
\    'systems',
\    'tattoo',
\    'technology',
\    'tel',
\    'tienda',
\    'tips',
\    'today',
\    'tokyo',
\    'tools',
\    'training',
\    'travel',
\    'uno',
\    'vacations',
\    'ventures',
\    'viajes',
\    'villas',
\    'vision',
\    'vote',
\    'voting',
\    'voto',
\    'voyage',
\    'wang',
\    'watch',
\    'wed',
\    'wien',
\    'wiki',
\    'works',
\    'xxx',
\    'xyz',
\    'zone',
\    'дети',
\    'онлайн',
\    'орг',
\    'сайт',
\    'بازار',
\    'شبكة',
\    'みんな',
\    '中信',
\    '中文网',
\    '公司',
\    '公益',
\    '在线',
\    '我爱你',
\    '政务',
\    '游戏',
\    '移动',
\    '网络',
\    '集团',
\    '삼성'
\   ], '\|')
\ )
let s:valid_ccTLD = printf(
\   '\%%(\%%(%s\)\)\%%([^0-9a-z@]\|$\)\@=',
\   join([
\     'ac',
\     'ad',
\     'ae',
\     'af',
\     'ag',
\     'ai',
\     'al',
\     'am',
\     'an',
\     'ao',
\     'aq',
\     'ar',
\     'as',
\     'at',
\     'au',
\     'aw',
\     'ax',
\     'az',
\     'ba',
\     'bb',
\     'bd',
\     'be',
\     'bf',
\     'bg',
\     'bh',
\     'bi',
\     'bj',
\     'bl',
\     'bm',
\     'bn',
\     'bo',
\     'bq',
\     'br',
\     'bs',
\     'bt',
\     'bv',
\     'bw',
\     'by',
\     'bz',
\     'ca',
\     'cc',
\     'cd',
\     'cf',
\     'cg',
\     'ch',
\     'ci',
\     'ck',
\     'cl',
\     'cm',
\     'cn',
\     'co',
\     'cr',
\     'cu',
\     'cv',
\     'cw',
\     'cx',
\     'cy',
\     'cz',
\     'de',
\     'dj',
\     'dk',
\     'dm',
\     'do',
\     'dz',
\     'ec',
\     'ee',
\     'eg',
\     'eh',
\     'er',
\     'es',
\     'et',
\     'eu',
\     'fi',
\     'fj',
\     'fk',
\     'fm',
\     'fo',
\     'fr',
\     'ga',
\     'gb',
\     'gd',
\     'ge',
\     'gf',
\     'gg',
\     'gh',
\     'gi',
\     'gl',
\     'gm',
\     'gn',
\     'gp',
\     'gq',
\     'gr',
\     'gs',
\     'gt',
\     'gu',
\     'gw',
\     'gy',
\     'hk',
\     'hm',
\     'hn',
\     'hr',
\     'ht',
\     'hu',
\     'id',
\     'ie',
\     'il',
\     'im',
\     'in',
\     'io',
\     'iq',
\     'ir',
\     'is',
\     'it',
\     'je',
\     'jm',
\     'jo',
\     'jp',
\     'ke',
\     'kg',
\     'kh',
\     'ki',
\     'km',
\     'kn',
\     'kp',
\     'kr',
\     'kw',
\     'ky',
\     'kz',
\     'la',
\     'lb',
\     'lc',
\     'li',
\     'lk',
\     'lr',
\     'ls',
\     'lt',
\     'lu',
\     'lv',
\     'ly',
\     'ma',
\     'mc',
\     'md',
\     'me',
\     'mf',
\     'mg',
\     'mh',
\     'mk',
\     'ml',
\     'mm',
\     'mn',
\     'mo',
\     'mp',
\     'mq',
\     'mr',
\     'ms',
\     'mt',
\     'mu',
\     'mv',
\     'mw',
\     'mx',
\     'my',
\     'mz',
\     'na',
\     'nc',
\     'ne',
\     'nf',
\     'ng',
\     'ni',
\     'nl',
\     'no',
\     'np',
\     'nr',
\     'nu',
\     'nz',
\     'om',
\     'pa',
\     'pe',
\     'pf',
\     'pg',
\     'ph',
\     'pk',
\     'pl',
\     'pm',
\     'pn',
\     'pr',
\     'ps',
\     'pt',
\     'pw',
\     'py',
\     'qa',
\     're',
\     'ro',
\     'rs',
\     'ru',
\     'rw',
\     'sa',
\     'sb',
\     'sc',
\     'sd',
\     'se',
\     'sg',
\     'sh',
\     'si',
\     'sj',
\     'sk',
\     'sl',
\     'sm',
\     'sn',
\     'so',
\     'sr',
\     'ss',
\     'st',
\     'su',
\     'sv',
\     'sx',
\     'sy',
\     'sz',
\     'tc',
\     'td',
\     'tf',
\     'tg',
\     'th',
\     'tj',
\     'tk',
\     'tl',
\     'tm',
\     'tn',
\     'to',
\     'tp',
\     'tr',
\     'tt',
\     'tv',
\     'tw',
\     'tz',
\     'ua',
\     'ug',
\     'uk',
\     'um',
\     'us',
\     'uy',
\     'uz',
\     'va',
\     'vc',
\     've',
\     'vg',
\     'vi',
\     'vn',
\     'vu',
\     'wf',
\     'ws',
\     'ye',
\     'yt',
\     'za',
\     'zm',
\     'zw',
\     'мон',
\     'рф',
\     'срб',
\     'укр',
\     'қаз',
\     'الاردن',
\     'الجزائر',
\     'السعودية',
\     'المغرب',
\     'امارات',
\     'ایران',
\     'بھارت',
\     'تونس',
\     'سودان',
\     'سورية',
\     'عمان',
\     'فلسطين',
\     'قطر',
\     'مصر',
\     'مليسيا',
\     'پاکستان',
\     'भारत',
\     'বাংলা',
\     'ভারত',
\     'ਭਾਰਤ',
\     'ભારત',
\     'இந்தியா',
\     'இலங்கை',
\     'சிங்கப்பூர்',
\     'భారత్',
\     'ලංකා',
\     'ไทย',
\     'გე',
\     '中国',
\     '中國',
\     '台湾',
\     '台灣',
\     '新加坡',
\     '香港',
\     '한국'
\   ], '\|')
\ )
let s:valid_punycode = '\%(xn--[0-9a-z]\+\)'
let s:valid_domain = printf(
\   '\%%(%s*%s\%%(%s\|%s\|%s\)\)',
\   s:valid_subdomain,
\   s:valid_domain_name,
\   s:valid_gTLD,
\   s:valid_ccTLD,
\   s:valid_punycode
\ )

let s:valid_ascii_domain = printf(
\   '\%%(\%%([A-Za-z0-9\-_]\|%s\)\+\.\)\+\%%(%s\|%s\|%s\)',
\   s:LATIN_ACCENTS,
\   s:valid_gTLD,
\   s:valid_ccTLD,
\   s:valid_punycode
\ )

let s:valid_tco_url = '\c^https\?://t\.co\/[a-z0-9]\+'

let s:invalid_short_domain = printf(
\   '%s%s',
\   s:valid_domain_name,
\   s:valid_ccTLD
\ )

let s:valid_port_number = '\d\+'

let s:valid_general_url_path_chars = printf(
\   '[a-z0-9!\*'';:=\+\,\.\$\/%%#\[\]\-_~&|@%s]',
\   s:LATIN_ACCENTS
\ )

let s:valid_url_balanced_parens = printf(
\   '(\%%(%s\+\|\%%(%s*(%s\+)%s*\)\))',
\   s:valid_general_url_path_chars,
\   s:valid_general_url_path_chars,
\   s:valid_general_url_path_chars,
\   s:valid_general_url_path_chars
\ )

let s:valid_url_path_ending_chars = printf(
\   '[a-z0-9=_#\/\+\-%s]\|\%%(%s\)',
\   s:LATIN_ACCENTS,
\   s:valid_url_balanced_parens
\ )

let s:valid_url_path = printf(
\   '\%%(\%%(%s*\%%(%s%s*\)*%s\)\|\%%(%s\+\/\)\)',
\   s:valid_general_url_path_chars,
\   s:valid_url_balanced_parens,
\   s:valid_general_url_path_chars,
\   s:valid_url_path_ending_chars,
\   s:valid_general_url_path_chars
\ )

let s:valid_url_query_chars = '[a-z0-9!?\*''\(\);:&=\+\$\/%#\[\]\-_\.,~|@]'
let s:valid_url_query_ending_chars = '[a-z0-9_&=#\/]'

let s:valid_url = printf(
\   '\c\(%s\)\(\(https\?://\)\?\(%s\)\%%(:\(%s\)\)\?\(/%s*\)\?\(?%s*%s\)\?\)',
\   s:valid_url_preceding_chars,
\   s:valid_domain,
\   s:valid_port_number,
\   s:valid_url_path,
\   s:valid_url_query_chars,
\   s:valid_url_query_ending_chars
\ )

let s:valid_url_syntax = printf(
\   '\c\%%(%s\|%s\zs%s\%%(:%s\)\?/%s*\%%(?%s*%s\)\?\|\%%(%s\zshttps\?://%s\|%s\zs\%%(\(%s\)\@=\%%(%s\)\@!\)\1\)\%%(:%s\)\?\%%(/%s*\)\?\%%(?%s*%s\)\?\)',
\   s:valid_tco_url,
\
\   s:valid_url_without_protocol_preceding_chars,
\   s:valid_ascii_domain,
\   s:valid_port_number,
\   s:valid_url_path,
\   s:valid_url_query_chars,
\   s:valid_url_query_ending_chars,
\
\   s:valid_url_preceding_chars,
\   s:valid_domain,
\   s:valid_url_without_protocol_preceding_chars,
\   s:valid_ascii_domain,
\   s:invalid_short_domain,
\   s:valid_port_number,
\   s:valid_url_path,
\   s:valid_url_query_chars,
\   s:valid_url_query_ending_chars
\ )

let s:valid_hashtag_syntax = printf(
\   '\c\%%(%s\)\zs\%%(#\|＃\)\%%(%s*%s%s*\)\@>%s\@!',
\   s:HASHTAG_BOUNDARY,
\   s:HASHTAG_ALPHANUMERIC,
\   s:HASHTAG_ALPHA,
\   s:HASHTAG_ALPHANUMERIC,
\   s:end_hashtag_match
\ )

let s:valid_mention_or_list_syntax = printf(
\   '%s\zs%s\%([a-zA-Z0-9_]\{1,20}\%(\/[a-zA-Z][a-zA-Z0-9_\-]\{0,24}\)\?\)\@>%s\@!',
\   s:valid_mention_preceding_chars,
\   s:at_signs,
\   s:end_mention_match
\ )

function! s:sub(conf)
  let [all, before, url, protocol, domain, port, path] = map(range(0, 6), 'submatch(v:val)')
  let after = ''
  if empty(protocol)
    if before =~? s:invalid_url_without_protocol_preceding_chars
      return all
    endif
    " I think the original algorithm contains a bug.  Uses other way.
    let ascii_domain = matchstr(domain, s:valid_ascii_domain . '$')
    if empty(ascii_domain) ||
    \   (ascii_domain =~? '^' . s:invalid_short_domain . '$' && empty(path))
      return all
    endif
    let cut_len = len(domain) - len(ascii_domain)
    if 0 < cut_len
      let before .= domain[: cut_len - 1]
    endif
  else
    let tco_url = matchstr(url, s:valid_tco_url)
    if !empty(tco_url)
      let after = url[len(tco_url) :]
    endif
  endif
  return before . repeat('.', s:short_url_length(a:conf, protocol)) . after
endfunction

function! s:short_url_length(conf, protocol)
  let key = a:protocol ==? 'https://' ? 'short_url_length_https'
  \                                   : 'short_url_length'
  return a:conf[key]
endfunction

function! tweetvim#tweet#count_chars(text)
  if !exists('s:twitter_configuration')
    let s:twitter_configuration = tweetvim#request('configuration', [])
  endif
  " check old regexpengine
  " check patch for iconv arguments
  if !exists('&regexpengine') || &regexpengine == 1
    return s:TWEET_LIMIT - strchars(a:text)
  end

  let conf = s:twitter_configuration
  let url_shorten_text = substitute(a:text, s:valid_url, '\=s:sub(conf)', 'g')
  return s:TWEET_LIMIT - strchars(url_shorten_text)
endfunction

function! tweetvim#tweet#mention_pattern()
  return s:valid_mention_or_list_syntax
endfunction

function! tweetvim#tweet#url_pattern()
  return s:valid_url_syntax
endfunction

function! tweetvim#tweet#hashtag_pattern()
  return s:valid_hashtag_syntax
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
