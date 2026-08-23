" =============================================================================
" mocha.vim  --  a Catppuccin-Mocha-flavoured colourscheme that you own
" =============================================================================
"
" Filename:    ~/.vim/colors/mocha.vim   (nvim reads the same file; see init.lua)
" Usage:       :colorscheme mocha
"
"
" WHY THIS FILE EXISTS
" --------------------
" This is a hand-rolled scheme in the *spirit* of Catppuccin Mocha: a soft dark
" background with pastel accents. It is deliberately NOT the catppuccin plugin,
" because that would be a plugin to fight with. Everything is here, in one
" vimscript file, so:
"
"   * plain vim on RHEL7 and nvim on your laptop use the SAME file (no drift),
"   * you can change any colour by editing one line,
"   * nothing needs a plugin manager, a C compiler, or network access.
"
" The palette values in section 2 are the Catppuccin Mocha ramp (MIT licensed,
" and already contrast-tested), used as a starting point. The structure around
" them -- roles, helper, group list -- is ours, and the palette is one block you
" can overwrite wholesale.
"
"
" HOW THIS FILE IS ORGANISED  (search for the numbered banners)
" ------------------------------------------------------------
"   1. OPTIONS      - the g:mocha_* switches (italics, transparency, contrast)
"   2. PALETTE      - the raw colours.  "I want a different green" -> here.
"   3. ROLES        - what each colour MEANS. "keywords should be blue" -> here.
"   4. HELPER       - the s:hi() function that writes :highlight commands.
"   5. EDITOR UI    - Normal, StatusLine, Pmenu, Visual, Search, diffs, ...
"   6. SYNTAX       - Comment, String, Function, Type, ... (vim's core groups)
"   7. TREESITTER   - the nvim @capture groups + LSP semantic tokens.
"   8. DIAGNOSTICS  - nvim LSP errors/warnings/hints.
"   9. PLUGINS      - telescope, oil, render-markdown.
"  10. Q / K        - groups your vim/syntax/{q,k}.vim files reference.
"  11. TERMINAL     - the 16 ANSI colours used by nvim's :terminal.
"  12. TOOLING      - :MochaPalette and :MochaWhat, for editing this file.
"
"
" THE THREE THINGS YOU'LL ACTUALLY DO
" -----------------------------------
" (a) "This colour is wrong."  Find the group name, change the role.
"     Put the cursor on the offending character and run:
"         nvim:  :Inspect            (shows treesitter + syntax + LSP groups)
"         vim:   :MochaWhat          (defined at the bottom of this file)
"     Then find that group name below and edit the role argument.
"
" (b) "I want a different palette."  Edit section 2. You do not need to touch
"     anything else -- every group refers to colours by NAME, never by hex.
"     To try values without editing this file at all, put a dict in your vimrc
"     BEFORE the :colorscheme line:
"         let g:mocha_palette = {'blue': ['#7aa2f7', 111], 'base': ['#16161e', 234]}
"     Each entry is [gui-hex, cterm-256-number].
"
" (c) "Reload and look at it."  :colorscheme mocha  re-sources this file.
"     There is no cache and no compile step.
"
"
" READING AN s:hi() LINE
" ----------------------
"     call s:hi('Comment', 'overlay1', '', s:italic)
"                 |          |         |      |
"                 group    foreground  bg    style
"
" Foreground/background/special are palette NAMES from section 2, or '' for
" "leave transparent / inherit". Style is one of the s:* style constants
" defined in section 1, or a literal like 'bold,underline'.
"
"
" COLOUR DEPTH
" ------------
" Every group is emitted twice: guifg/guibg (24-bit, used when 'termguicolors'
" is on) and ctermfg/ctermbg (the 256-colour approximation). So:
"
"   nvim + modern terminal   -> termguicolors on, exact hex.        Best case.
"   vim 8 / nvim, no truecol -> 256-colour approximation. Very close.
"   vim 7.4 on RHEL7         -> same 256-colour path. Works.
"   8/16-colour terminal     -> will look wrong. Set TERM to a -256color entry.
"
" The cterm numbers deliberately avoid 0-15: those sixteen are whatever the
" terminal profile defines, so using them would make the scheme change shape
" from machine to machine.
"
" =============================================================================

hi clear
if exists('syntax_on')
  syntax reset
endif

set background=dark
let g:colors_name = 'mocha'


" =============================================================================
" 1. OPTIONS
" =============================================================================
" Set any of these in your vimrc / init.lua BEFORE :colorscheme mocha.
" Defaults are on the right of each get() call.
"
"   let g:mocha_transparent     = 1   " don't paint the background at all, so
"                                     " the terminal's own background shows
"                                     " through (useful with a transparent
"                                     " terminal or a background image)
"   let g:mocha_italic_comments = 0   " turn off italic comments
"   let g:mocha_italic_keywords = 1   " italicise keywords too
"   let g:mocha_bold_functions  = 1   " bold function names
"   let g:mocha_dim_inactive    = 0   " make unfocused splits the same as focused
"   let g:mocha_contrast        = 'hard'   " 'default' | 'hard'
"   let g:mocha_palette         = {...}    " see (b) in the header
"
" 'hard' contrast drops the editor background from base (#1e1e2e) to crust
" (#11111b), which reads better on a bright monitor or a cheap projector.

let s:transparent     = get(g:, 'mocha_transparent',     1)
let s:italic_comments = get(g:, 'mocha_italic_comments', 0)
let s:italic_keywords = get(g:, 'mocha_italic_keywords', 0)
let s:bold_functions  = get(g:, 'mocha_bold_functions',  0)
let s:dim_inactive    = get(g:, 'mocha_dim_inactive',    1)
let s:contrast        = get(g:, 'mocha_contrast',        'default')

" Style constants. Referred to as s:italic etc. so that flipping one option
" above changes every group that uses it, instead of you editing 40 lines.
let s:none      = 'NONE'
let s:bold      = 'bold'
let s:underline = 'underline'
let s:undercurl = 'undercurl'
let s:reverse   = 'reverse'
let s:italic    = s:italic_comments ? 'italic' : 'NONE'
let s:kw_italic = s:italic_keywords ? 'italic' : 'NONE'
let s:fn_bold   = s:bold_functions  ? 'bold'   : 'NONE'


" =============================================================================
" 2. PALETTE
" =============================================================================
" name -> [gui hex, cterm-256 number]
"
" The ramp has a shape worth preserving when you edit it:
"
"   crust/mantle/base        the three background tiers, darkest first.
"                            base is the editor background; mantle is for
"                            things that sit *behind* it (statusline, tabline);
"                            crust is the deepest, used for borders and shadow.
"   surface0/1/2             raised backgrounds: cursorline, selections, popups.
"   overlay0/1/2             muted foregrounds: comments, line numbers, borders.
"   subtext0/subtext1/text   real foreground text, dimmest to brightest.
"   the 14 accents           hue names, not role names, on purpose -- section 3
"                            is where a hue gets a job. That indirection is why
"                            "make strings green instead of yellow" is a
"                            one-line change in section 3, and why swapping the
"                            whole palette here doesn't break anything.
"
" cterm fallbacks: the background/foreground tiers map to the 232-255 greyscale
" ramp, which is more neutral than the true hex (which leans blue-violet). That
" is a deliberate trade -- the greys stay correctly ORDERED in 256-colour mode,
" which matters more than hue fidelity when you're on an old box.

let s:palette = {
      \ 'crust':     ['#11111b', 233],
      \ 'mantle':    ['#181825', 234],
      \ 'base':      ['#1e1e2e', 235],
      \ 'surface0':  ['#313244', 236],
      \ 'surface1':  ['#45475a', 238],
      \ 'surface2':  ['#585b70', 240],
      \ 'overlay0':  ['#6c7086', 242],
      \ 'overlay1':  ['#7f849c', 244],
      \ 'overlay2':  ['#9399b2', 247],
      \ 'subtext0':  ['#a6adc8', 249],
      \ 'subtext1':  ['#bac2de', 251],
      \ 'text':      ['#cdd6f4', 253],
      \ 'rosewater': ['#f5e0dc', 224],
      \ 'flamingo':  ['#f2cdcd', 217],
      \ 'pink':      ['#f5c2e7', 218],
      \ 'mauve':     ['#cba6f7', 183],
      \ 'red':       ['#f38ba8', 211],
      \ 'maroon':    ['#eba0ac', 181],
      \ 'peach':     ['#fab387', 216],
      \ 'yellow':    ['#f9e2af', 223],
      \ 'green':     ['#a6e3a1', 151],
      \ 'teal':      ['#94e2d5', 116],
      \ 'sky':       ['#89dceb', 117],
      \ 'sapphire':  ['#74c7ec',  74],
      \ 'blue':      ['#89b4fa', 111],
      \ 'lavender':  ['#b4befe', 147],
      \ }

" Per-machine overrides from the vimrc, e.g. a lighter background on the work
" box only. Merged after the defaults so you only name what you're changing.
if exists('g:mocha_palette')
  call extend(s:palette, g:mocha_palette)
endif


" =============================================================================
" 3. ROLES
" =============================================================================
" This section is the interesting one. It maps a JOB to a hue, and sections 5-10
" only ever mention jobs. Want keywords blue instead of mauve? Change one line
" here and every keyword-ish group in every language follows -- including the
" treesitter groups and the q/k syntax files.
"
" These are just palette names, so a role can point at another role too.

let s:bg        = s:contrast ==# 'hard' ? 'crust' : 'base'
let s:bg_alt    = 'mantle'      " statusline, tabline -- one tier off s:bg either
                                " way, so the bar stays visible in both contrasts
let s:bg_float  = 'mantle'      " popup / floating window background
let s:bg_sel    = 'surface1'    " visual selection
let s:bg_cursor = 'surface0'    " cursorline / cursorcolumn
let s:border    = 'surface2'    " window separators, float borders

let s:fg        = 'text'        " normal text
let s:fg_dim    = 'subtext0'    " labels, less important text
let s:fg_mute   = 'overlay1'    " line numbers, whitespace markers, quotes

" CONTRAST, measured (WCAG ratio against the #1e1e2e background):
"
"   text 11.3   subtext1 9.3   subtext0 7.4   overlay2 5.8
"   overlay1 4.4   overlay0 3.4   surface2 2.5
"   every accent 7.1 - 12.9 (dimmest: red 7.1, brightest: rosewater 13.0)
"
" 4.5 is the AA threshold for body text, 3.0 for UI chrome. So: every accent
" and every text tier is comfortably AA on the normal background, overlay1/0
" are chrome-only on purpose, and the numbers drop by about a third on top of
" CursorLine (surface0) and by half on top of Visual (surface1) -- which is why
" comments use overlay2 rather than the dimmer overlay1. If you want comments
" to recede harder, overlay1 (4.4) or overlay0 (3.4) is the knob; both are
" legible on the normal background and get muddy on the current line.

" Syntax roles. The left column is the job; change the right column freely.
let s:r_comment  = 'overlay2'   " comments
let s:r_keyword  = 'mauve'      " if / for / return / def
let s:r_operator = 'sky'        " + - * / = ->
let s:r_func     = 'blue'       " function names and calls
let s:r_type     = 'yellow'     " types, classes, structs
let s:r_string   = 'green'      " string literals
let s:r_number   = 'peach'      " numbers, booleans, chars
let s:r_const    = 'peach'      " constants, enum members
let s:r_var      = 'text'       " plain variables
let s:r_param    = 'maroon'     " function parameters
let s:r_field    = 'lavender'   " obj.field / struct members
let s:r_builtin  = 'red'        " builtins: self, None, True, len()
let s:r_preproc  = 'pink'       " #include, decorators, macros
let s:r_special  = 'pink'       " escape sequences, format specifiers
let s:r_punct    = 'overlay2'   " brackets, commas, semicolons
let s:r_tag      = 'blue'       " HTML/XML tag names
let s:r_label    = 'sapphire'   " goto labels, dict keys in some langs

" Semantic roles used by UI, diffs, diagnostics and plugins.
let s:r_error    = 'red'
let s:r_warn     = 'yellow'
let s:r_info     = 'sky'
let s:r_hint     = 'teal'
let s:r_ok       = 'green'
let s:r_added    = 'green'
let s:r_changed  = 'yellow'
let s:r_removed  = 'red'
let s:r_search   = 'sky'        " background of search matches
let s:r_match    = 'peach'      " matching bracket, fuzzy-match characters
let s:r_accent   = 'lavender'   " titles, headings, "you are here" markers


" =============================================================================
" 4. HELPER
" =============================================================================
" You should not need to change anything in this section. It exists so the rest
" of the file reads as data rather than as string concatenation.

" Resolve a palette name to its gui hex, or NONE.
function! s:gui(name) abort
  if a:name ==# '' || a:name ==# 'NONE' | return 'NONE' | endif
  return has_key(s:palette, a:name) ? s:palette[a:name][0] : a:name
endfunction

" Resolve a palette name to its cterm number, or NONE.
function! s:ct(name) abort
  if a:name ==# '' || a:name ==# 'NONE' | return 'NONE' | endif
  return has_key(s:palette, a:name) ? s:palette[a:name][1] : 'NONE'
endfunction

" cterm has no undercurl before vim 8 (and no guisp at all), so degrade to a
" plain underline for the terminal attribute while keeping undercurl for gui.
function! s:ct_style(style) abort
  return substitute(a:style, 'undercurl', 'underline', 'g')
endfunction

" s:hi(group, fg, bg, style [, sp])
"   group  highlight group name
"   fg/bg  palette name, or '' for none
"   style  'NONE', 'bold', 'italic,underline', or an s:* constant
"   sp     palette name for guisp (the undercurl/underline colour)
function! s:hi(group, fg, bg, style, ...) abort
  let l:sp = get(a:000, 0, '')
  let l:style = a:style ==# '' ? 'NONE' : a:style
  let l:cmd  = 'highlight ' . a:group
  let l:cmd .= ' guifg='   . s:gui(a:fg)   . ' ctermfg=' . s:ct(a:fg)
  let l:cmd .= ' guibg='   . s:gui(a:bg)   . ' ctermbg=' . s:ct(a:bg)
  let l:cmd .= ' gui='     . l:style       . ' cterm='   . s:ct_style(l:style)
  let l:cmd .= ' guisp='   . s:gui(l:sp)
  execute l:cmd
endfunction

" s:link(from, to) -- 'from' becomes an alias of 'to'. Cheaper than repeating a
" definition, and it means retheming 'to' retheme's every alias with it.
function! s:link(from, to) abort
  execute 'highlight! link ' . a:from . ' ' . a:to
endfunction

" With transparency on, any group whose background is the editor background
" must instead have no background at all. Route those through s:hi_bg().
let s:bg_eff = s:transparent ? '' : s:bg


" =============================================================================
" 5. EDITOR UI
" =============================================================================
" Everything that isn't code text: the frame around your buffer.

" -- the buffer itself --------------------------------------------------------
call s:hi('Normal',        s:fg,       s:bg_eff,    s:none)
call s:hi('NormalFloat',   s:fg,       s:bg_float,  s:none)   " nvim popups
call s:hi('FloatBorder',   s:border,   s:bg_float,  s:none)
call s:hi('FloatTitle',    s:r_accent, s:bg_float,  s:bold)
call s:hi('FloatShadow',   '',         'crust',     s:none)
call s:link('FloatShadowThrough', 'FloatShadow')

" NormalNC is the text in *non-current* windows (nvim only). Dimming it makes
" "which split am I in" obvious at a glance. g:mocha_dim_inactive = 0 to stop.
if s:dim_inactive
  call s:hi('NormalNC',    s:fg_dim,   s:transparent ? '' : 'mantle', s:none)
else
  call s:link('NormalNC', 'Normal')
endif

" -- cursor and current line -------------------------------------------------
" Cursor/lCursor only apply in GUI vim and in nvim's :terminal; a terminal vim
" draws the cursor with the terminal's own colour. Harmless to define.
call s:hi('Cursor',        'base',     'rosewater', s:none)
call s:link('lCursor',     'Cursor')
call s:link('CursorIM',    'Cursor')
call s:link('TermCursor',  'Cursor')
call s:hi('TermCursorNC',  'base',     'overlay0',  s:none)

call s:hi('CursorLine',    '',         s:bg_cursor, s:none)
call s:hi('CursorColumn',  '',         s:bg_cursor, s:none)
call s:hi('ColorColumn',   '',         'surface0',  s:none)  " the 'colorcolumn' ruler

" Line numbers. Your old scheme forced these to hard Blue/Yellow from the vimrc;
" that override has been removed so these two lines are now the only place they
" are decided.
call s:hi('LineNr',        s:fg_mute,  '',          s:none)
call s:hi('CursorLineNr',  s:r_accent, '',          s:bold)
call s:link('LineNrAbove', 'LineNr')
call s:link('LineNrBelow', 'LineNr')
call s:hi('CursorLineFold','overlay0', s:bg_cursor, s:none)
call s:hi('CursorLineSign','',         s:bg_cursor, s:none)

" -- gutters, folds, splits --------------------------------------------------
call s:hi('SignColumn',    'overlay0', '',          s:none)
call s:hi('FoldColumn',    'overlay0', '',          s:none)
call s:hi('Folded',        'blue',     'surface0',  s:none)
call s:hi('VertSplit',     s:border,   '',          s:none)  " vim name
call s:link('WinSeparator','VertSplit')                      " nvim name

" -- statusline and tabline --------------------------------------------------
" A statusline plugin (lualine et al) would override these; you have none, so
" this is what you actually see.
call s:hi('StatusLine',    s:fg,       'surface0',  s:none)
call s:hi('StatusLineNC',  'overlay0', s:bg_alt,    s:none)
call s:hi('StatusLineTerm',   'green', 'surface0',  s:bold)
call s:hi('StatusLineTermNC', 'green', s:bg_alt,    s:none)
call s:hi('WinBar',        s:r_accent, '',          s:bold)
call s:hi('WinBarNC',      'overlay0', '',          s:none)

call s:hi('TabLine',       'overlay0', s:bg_alt,    s:none)
call s:hi('TabLineFill',   '',         'crust',     s:none)
call s:hi('TabLineSel',    s:r_accent, s:bg,        s:bold)

" -- messages ----------------------------------------------------------------
call s:hi('ModeMsg',       s:fg,       '',          s:bold)   " -- INSERT --
call s:hi('MoreMsg',       'green',    '',          s:bold)   " -- More --
call s:hi('Question',      'green',    '',          s:none)   " prompts
call s:hi('WarningMsg',    s:r_warn,   '',          s:bold)
call s:hi('ErrorMsg',      s:r_error,  '',          s:bold)
call s:hi('MsgArea',       s:fg,       '',          s:none)
call s:hi('MsgSeparator',  s:border,   s:bg_float,  s:none)
call s:hi('Error',         s:r_error,  '',          s:bold)

" -- selection, search, matching ---------------------------------------------
call s:hi('Visual',        '',         s:bg_sel,    s:none)
call s:hi('VisualNOS',     '',         s:bg_sel,    s:none)

" Search: dark text on a coloured block. CurSearch (nvim) / the match you are
" standing on gets the louder colour so you can tell it from the other hits.
call s:hi('Search',        'crust',    s:r_search,  s:bold)
call s:hi('CurSearch',     'crust',    s:r_match,   s:bold)
call s:hi('IncSearch',     'crust',    s:r_match,   s:bold)
call s:hi('Substitute',    'crust',    s:r_removed, s:bold)   " :s preview
call s:hi('MatchParen',    s:r_match,  'surface1',  s:bold)
call s:hi('QuickFixLine',  '',         'surface0',  s:bold)

" -- popup menu (completion) -------------------------------------------------
call s:hi('Pmenu',         s:fg_dim,   s:bg_float,  s:none)
call s:hi('PmenuSel',      s:fg,       'surface1',  s:bold)
call s:hi('PmenuSbar',     '',         'surface0',  s:none)
call s:hi('PmenuThumb',    '',         'surface2',  s:none)
call s:hi('PmenuKind',     s:r_type,   s:bg_float,  s:none)   " the "[Function]" column
call s:hi('PmenuKindSel',  s:r_type,   'surface1',  s:bold)
call s:hi('PmenuExtra',    'overlay0', s:bg_float,  s:none)   " the trailing detail column
call s:hi('PmenuExtraSel', s:fg_dim,   'surface1',  s:bold)
call s:hi('PmenuMatch',    s:r_match,  s:bg_float,  s:bold)   " matched characters
call s:hi('PmenuMatchSel', s:r_match,  'surface1',  s:bold)
call s:link('ComplMatchIns', 'PmenuMatch')
call s:hi('WildMenu',      'crust',    s:r_accent,  s:bold)
call s:link('PopupSelected', 'PmenuSel')
call s:link('PopupNotification', 'WarningMsg')
call s:link('MessageWindow', 'NormalFloat')

" -- invisibles and misc -----------------------------------------------------
call s:hi('NonText',       'surface2', '',          s:none)   " '@' past end, eol markers
call s:hi('EndOfBuffer',   'surface1', '',          s:none)   " the '~' lines
call s:hi('Whitespace',    'surface1', '',          s:none)   " 'listchars' dots/tabs
call s:hi('SpecialKey',    'surface2', '',          s:none)
call s:hi('Conceal',       'overlay0', '',          s:none)
call s:hi('Directory',     'blue',     '',          s:bold)   " netrw/oil dir names
call s:hi('Title',         s:r_accent, '',          s:bold)
call s:hi('Ignore',        'overlay0', '',          s:none)
call s:hi('Todo',          'crust',    s:r_warn,    s:bold)   " TODO/FIXME/XXX

" -- spelling (undercurl in gui, underline in cterm) -------------------------
call s:hi('SpellBad',   '', '', s:undercurl, s:r_error)
call s:hi('SpellCap',   '', '', s:undercurl, s:r_warn)
call s:hi('SpellLocal', '', '', s:undercurl, s:r_info)
call s:hi('SpellRare',  '', '', s:undercurl, 'mauve')

" -- diffs -------------------------------------------------------------------
" Backgrounds only, tinted very dark, so the code on top stays readable. If you
" find these too subtle, bump surface0/1 or swap in the accent itself as bg
" (and then set a dark fg, or the text will vanish).
call s:hi('DiffAdd',       '',         'surface0',  s:none)
call s:hi('DiffChange',    '',         'surface0',  s:none)
call s:hi('DiffDelete',    s:r_removed,'mantle',    s:none)
call s:hi('DiffText',      'crust',    s:r_changed, s:bold)   " the changed run itself
call s:link('DiffTextAdd', 'DiffText')

" git's own syntax groups, used when you edit a patch or a commit message
call s:hi('diffAdded',     s:r_added,  '',          s:none)
call s:hi('diffRemoved',   s:r_removed,'',          s:none)
call s:hi('diffChanged',   s:r_changed,'',          s:none)
call s:hi('diffOldFile',   s:r_removed,'',          s:none)
call s:hi('diffNewFile',   s:r_added,  '',          s:none)
call s:hi('diffFile',      'blue',     '',          s:bold)
call s:hi('diffLine',      'overlay2', '',          s:none)
call s:hi('diffIndexLine', 'mauve',    '',          s:none)
call s:hi('Added',         s:r_added,  '',          s:none)
call s:hi('Changed',       s:r_changed,'',          s:none)
call s:hi('Removed',       s:r_removed,'',          s:none)
call s:link('PreInsert', 'Added')

" -- text styles -------------------------------------------------------------
call s:hi('Bold',          '',         '',          s:bold)
call s:hi('Italic',        '',         '',          'italic')
call s:hi('BoldItalic',    '',         '',          'bold,italic')
call s:hi('Underlined',    '',         '',          s:underline)


" =============================================================================
" 6. SYNTAX  (vim's core groups)
" =============================================================================
" These 30-odd groups are what plain vim syntax files -- including your
" vim/syntax/q.vim and vim/syntax/k.vim -- link into. Get these right and every
" language gets themed, even with no treesitter and no LSP. Section 7 refines
" the picture where nvim has better information.

call s:hi('Comment',       s:r_comment,  '', s:italic)

" Constants and literals
call s:hi('Constant',      s:r_const,    '', s:none)
call s:hi('String',        s:r_string,   '', s:none)
call s:hi('Character',     s:r_string,   '', s:none)
call s:hi('Number',        s:r_number,   '', s:none)
call s:hi('Float',         s:r_number,   '', s:none)
call s:hi('Boolean',       s:r_number,   '', s:none)

" Names
call s:hi('Identifier',    s:r_var,      '', s:none)
call s:hi('Function',      s:r_func,     '', s:fn_bold)
call s:hi('Variable',      s:r_var,      '', s:none)  " not a stock vim group;
                                                      " vim/syntax/k.vim links
                                                      " k_i to it, so it must
                                                      " exist or k identifiers
                                                      " render unhighlighted.

" Statements and keywords
call s:hi('Statement',     s:r_keyword,  '', s:kw_italic)
call s:hi('Conditional',   s:r_keyword,  '', s:kw_italic)
call s:hi('Repeat',        s:r_keyword,  '', s:kw_italic)
call s:hi('Label',         s:r_label,    '', s:none)
call s:hi('Operator',      s:r_operator, '', s:none)
call s:hi('Keyword',       s:r_keyword,  '', s:kw_italic)
call s:hi('Exception',     s:r_builtin,  '', s:kw_italic)

" Preprocessor / imports / decorators
call s:hi('PreProc',       s:r_preproc,  '', s:none)
call s:hi('Include',       s:r_preproc,  '', s:none)
call s:hi('Define',        s:r_preproc,  '', s:none)
call s:hi('Macro',         s:r_preproc,  '', s:none)
call s:hi('PreCondit',     s:r_preproc,  '', s:none)

" Types
call s:hi('Type',          s:r_type,     '', s:none)
call s:hi('StorageClass',  s:r_type,     '', s:none)
call s:hi('Structure',     s:r_type,     '', s:none)
call s:hi('Typedef',       s:r_type,     '', s:none)

" Special
call s:hi('Special',       s:r_special,  '', s:none)
call s:hi('SpecialChar',   s:r_special,  '', s:none)
call s:hi('Tag',           s:r_tag,      '', s:none)
call s:hi('Delimiter',     s:r_punct,    '', s:none)
call s:hi('SpecialComment',s:r_comment,  '', s:bold)
call s:hi('Debug',         s:r_error,    '', s:none)


" =============================================================================
" 7. TREESITTER + LSP SEMANTIC TOKENS  (nvim only, harmless in vim)
" =============================================================================
" nvim's highlighter emits @-prefixed groups, which fall back to the section 6
" groups when undefined. Defining them explicitly buys real precision: a
" function *parameter* can differ from a *local variable*, which plain vim
" syntax cannot express.
"
" You have no nvim-treesitter plugin (no C compiler -- see README), so these
" apply to the parsers bundled with nvim: markdown, vim, vimdoc, lua, query,
" c, and whatever the LSP reports as semantic tokens.
"
" Naming convention: @thing.modifier, most specific wins. To find the exact
" capture under your cursor: :Inspect

if has('nvim')
  " variables
  call s:hi('@variable',            s:r_var,     '', s:none)
  call s:hi('@variable.builtin',    s:r_builtin, '', s:none)  " self, this
  call s:hi('@variable.parameter',  s:r_param,   '', s:none)
  call s:hi('@variable.member',     s:r_field,   '', s:none)  " obj.field
  call s:link('@property', '@variable.member')

  " constants and modules
  call s:hi('@constant',            s:r_const,   '', s:none)
  call s:hi('@constant.builtin',    s:r_builtin, '', s:none)  " None, True, nil
  call s:hi('@constant.macro',      s:r_preproc, '', s:none)
  call s:hi('@module',              s:r_type,    '', s:none)  " module/namespace
  call s:hi('@label',               s:r_label,   '', s:none)  " goto labels, :key

  " literals
  call s:hi('@string',              s:r_string,  '', s:none)
  call s:hi('@string.documentation',s:r_string,  '', s:italic)
  call s:hi('@string.escape',       s:r_special, '', s:bold)   " \n \t
  call s:hi('@string.regexp',       s:r_special, '', s:none)
  call s:hi('@string.special',      s:r_special, '', s:none)
  call s:hi('@string.special.url',  'sapphire',  '', s:underline)
  call s:hi('@character',           s:r_string,  '', s:none)
  call s:hi('@character.special',   s:r_special, '', s:none)
  call s:hi('@number',              s:r_number,  '', s:none)
  call s:hi('@number.float',        s:r_number,  '', s:none)
  call s:hi('@boolean',             s:r_number,  '', s:none)

  " functions
  call s:hi('@function',            s:r_func,    '', s:fn_bold)
  call s:hi('@function.builtin',    s:r_builtin, '', s:none)   " len(), print()
  call s:hi('@function.call',       s:r_func,    '', s:none)
  call s:hi('@function.method',     s:r_func,    '', s:none)
  call s:hi('@function.method.call',s:r_func,    '', s:none)
  call s:hi('@function.macro',      s:r_preproc, '', s:none)
  call s:hi('@constructor',         s:r_type,    '', s:none)

  " keywords and operators
  call s:hi('@keyword',             s:r_keyword, '', s:kw_italic)
  call s:hi('@keyword.function',    s:r_keyword, '', s:kw_italic)  " def, lambda
  call s:hi('@keyword.operator',    s:r_keyword, '', s:none)       " and, or, not
  call s:hi('@keyword.return',      s:r_builtin, '', s:kw_italic)
  call s:hi('@keyword.import',      s:r_preproc, '', s:none)
  call s:hi('@keyword.exception',   s:r_builtin, '', s:kw_italic)
  call s:hi('@keyword.conditional', s:r_keyword, '', s:kw_italic)
  call s:hi('@keyword.repeat',      s:r_keyword, '', s:kw_italic)
  call s:hi('@keyword.directive',   s:r_preproc, '', s:none)
  call s:hi('@operator',            s:r_operator,'', s:none)

  " types
  call s:hi('@type',                s:r_type,    '', s:none)
  call s:hi('@type.builtin',        s:r_type,    '', s:italic)
  call s:hi('@type.definition',     s:r_type,    '', s:none)
  call s:hi('@attribute',           s:r_preproc, '', s:none)      " @decorator

  " punctuation -- dimmer than the code, so structure recedes and names pop
  call s:hi('@punctuation.delimiter', s:r_punct, '', s:none)
  call s:hi('@punctuation.bracket',   s:r_punct, '', s:none)
  call s:hi('@punctuation.special',   s:r_special, '', s:none)     " f-string {}

  " comments
  call s:hi('@comment',             s:r_comment, '', s:italic)
  call s:hi('@comment.todo',        'crust',     s:r_info,   s:bold)
  call s:hi('@comment.note',        'crust',     s:r_hint,   s:bold)
  call s:hi('@comment.warning',     'crust',     s:r_warn,   s:bold)
  call s:hi('@comment.error',       'crust',     s:r_error,  s:bold)

  " markup -- markdown, and anything with prose. Pairs with render-markdown.
  call s:hi('@markup.heading',      s:r_accent,  '', s:bold)
  call s:hi('@markup.heading.1',    'red',       '', s:bold)
  call s:hi('@markup.heading.2',    'peach',     '', s:bold)
  call s:hi('@markup.heading.3',    'yellow',    '', s:bold)
  call s:hi('@markup.heading.4',    'green',     '', s:bold)
  call s:hi('@markup.heading.5',    'sapphire',  '', s:bold)
  call s:hi('@markup.heading.6',    'lavender',  '', s:bold)
  call s:hi('@markup.strong',       s:fg,        '', s:bold)
  call s:hi('@markup.italic',       s:fg,        '', 'italic')
  call s:hi('@markup.strikethrough',s:fg_mute,   '', 'strikethrough')
  call s:hi('@markup.underline',    '',          '', s:underline)
  call s:hi('@markup.quote',        s:fg_dim,    '', s:italic)
  call s:hi('@markup.math',         'sapphire',  '', s:none)
  call s:hi('@markup.link',         'lavender',  '', s:none)
  call s:hi('@markup.link.label',   'sapphire',  '', s:none)
  call s:hi('@markup.link.url',     'sapphire',  '', s:underline)
  call s:hi('@markup.raw',          s:r_string,  '', s:none)       " `inline code`
  call s:hi('@markup.raw.block',    s:fg_dim,    '', s:none)       " ``` blocks
  call s:hi('@markup.list',         'peach',     '', s:none)
  call s:hi('@markup.list.checked', 'green',     '', s:none)
  call s:hi('@markup.list.unchecked', 'overlay1','', s:none)

  " tags (HTML/XML/JSX)
  call s:hi('@tag',                 s:r_tag,     '', s:none)
  call s:hi('@tag.attribute',       s:r_type,    '', s:italic)
  call s:hi('@tag.delimiter',       s:r_punct,   '', s:none)

  " diff files
  call s:hi('@diff.plus',           s:r_added,   '', s:none)
  call s:hi('@diff.minus',          s:r_removed, '', s:none)
  call s:hi('@diff.delta',          s:r_changed, '', s:none)

  " LSP semantic tokens. These arrive from basedpyright/clangd/ruff and sit on
  " TOP of treesitter, so if a colour looks wrong in a real project but right
  " in a scratch buffer, suspect this block. Linking (rather than defining)
  " keeps them consistent with the treesitter groups above by construction.
  call s:link('@lsp.type.class',         '@type')
  call s:link('@lsp.type.comment',       '@comment')
  call s:link('@lsp.type.decorator',     '@attribute')
  call s:link('@lsp.type.enum',          '@type')
  call s:link('@lsp.type.enumMember',    '@constant')
  call s:link('@lsp.type.function',      '@function')
  call s:link('@lsp.type.interface',     '@type')
  call s:link('@lsp.type.macro',         '@function.macro')
  call s:link('@lsp.type.method',        '@function.method')
  call s:link('@lsp.type.namespace',     '@module')
  call s:link('@lsp.type.parameter',     '@variable.parameter')
  call s:link('@lsp.type.property',      '@variable.member')
  call s:link('@lsp.type.struct',        '@type')
  call s:link('@lsp.type.type',          '@type')
  call s:link('@lsp.type.typeParameter', '@type.definition')
  call s:link('@lsp.type.variable',      '@variable')
  call s:link('@lsp.typemod.function.defaultLibrary', '@function.builtin')
  call s:link('@lsp.typemod.variable.defaultLibrary', '@variable.builtin')
  call s:link('@lsp.typemod.variable.readonly',       '@constant')
endif


" =============================================================================
" 8. DIAGNOSTICS  (nvim LSP)
" =============================================================================
" Four severities, each themed three ways: the sign in the gutter, the virtual
" text at end of line, and the undercurl on the offending code.
" init.lua sets virtual_text = { prefix = '*' } -- that '*' is DiagnosticVirtualTextX.

if has('nvim')
  call s:hi('DiagnosticError', s:r_error, '', s:none)
  call s:hi('DiagnosticWarn',  s:r_warn,  '', s:none)
  call s:hi('DiagnosticInfo',  s:r_info,  '', s:none)
  call s:hi('DiagnosticHint',  s:r_hint,  '', s:none)
  call s:hi('DiagnosticOk',    s:r_ok,    '', s:none)

  " Virtual text: italic and unbackgrounded, so it reads as annotation rather
  " than as code. Add a bg here (e.g. 'surface0') if you want it to stand out.
  call s:hi('DiagnosticVirtualTextError', s:r_error, '', s:italic)
  call s:hi('DiagnosticVirtualTextWarn',  s:r_warn,  '', s:italic)
  call s:hi('DiagnosticVirtualTextInfo',  s:r_info,  '', s:italic)
  call s:hi('DiagnosticVirtualTextHint',  s:r_hint,  '', s:italic)
  call s:hi('DiagnosticVirtualTextOk',    s:r_ok,    '', s:italic)

  " Underlines: colour comes from guisp, so the code keeps its own fg colour.
  call s:hi('DiagnosticUnderlineError', '', '', s:undercurl, s:r_error)
  call s:hi('DiagnosticUnderlineWarn',  '', '', s:undercurl, s:r_warn)
  call s:hi('DiagnosticUnderlineInfo',  '', '', s:undercurl, s:r_info)
  call s:hi('DiagnosticUnderlineHint',  '', '', s:undercurl, s:r_hint)
  call s:hi('DiagnosticUnderlineOk',    '', '', s:undercurl, s:r_ok)

  call s:link('DiagnosticFloatingError', 'DiagnosticError')
  call s:link('DiagnosticFloatingWarn',  'DiagnosticWarn')
  call s:link('DiagnosticFloatingInfo',  'DiagnosticInfo')
  call s:link('DiagnosticFloatingHint',  'DiagnosticHint')
  call s:link('DiagnosticFloatingOk',    'DiagnosticOk')
  call s:link('DiagnosticSignError',     'DiagnosticError')
  call s:link('DiagnosticSignWarn',      'DiagnosticWarn')
  call s:link('DiagnosticSignInfo',      'DiagnosticInfo')
  call s:link('DiagnosticSignHint',      'DiagnosticHint')
  call s:link('DiagnosticSignOk',        'DiagnosticOk')
  call s:link('DiagnosticDeprecated',    '@markup.strikethrough')
  call s:hi('DiagnosticUnnecessary', 'overlay0', '', s:none)  " unused imports

  " Reference highlights: where else in this file is the symbol under the
  " cursor? Backgrounds only, so the syntax colour survives.
  call s:hi('LspReferenceText',  '', 'surface1', s:none)
  call s:hi('LspReferenceRead',  '', 'surface1', s:none)
  call s:hi('LspReferenceWrite', '', 'surface1', s:bold)
  call s:hi('LspReferenceTarget','', 'surface1', s:none)
  call s:hi('LspInlayHint',      'overlay0', 'mantle', s:italic)
  call s:hi('LspCodeLens',       'overlay0', '',       s:italic)
  call s:hi('LspCodeLensSeparator', 'overlay0', '',    s:none)
  call s:hi('LspSignatureActiveParameter', 'crust', s:r_match, s:bold)
  call s:link('SnippetTabstop', 'Visual')
endif


" =============================================================================
" 9. PLUGINS
" =============================================================================
" Only the plugins you actually have in nvim/init.lua. Adding a plugin later?
" Its README lists its highlight groups; add a block here in the same shape,
" and prefer s:link() to a group above so it inherits future palette edits.

" -- telescope (<leader>ff / fg / fb) ----------------------------------------
" Three panes: prompt (top), results (left), preview (right). Giving the prompt
" a distinct background is what makes the box read as a dialog and not as text.
call s:hi('TelescopeNormal',        s:fg_dim,   'mantle',   s:none)
call s:hi('TelescopeBorder',        'mantle',   'mantle',   s:none)
call s:hi('TelescopeTitle',         'overlay0', '',         s:none)
call s:hi('TelescopePromptNormal',  s:fg,       'surface0', s:none)
call s:hi('TelescopePromptBorder',  'surface0', 'surface0', s:none)
call s:hi('TelescopePromptTitle',   'crust',    s:r_accent, s:bold)
call s:hi('TelescopePromptPrefix',  s:r_error,  'surface0', s:none)   " the '>'
call s:hi('TelescopeResultsNormal', s:fg_dim,   'mantle',   s:none)
call s:hi('TelescopeResultsBorder', 'mantle',   'mantle',   s:none)
call s:hi('TelescopeResultsTitle',  'mantle',   'mantle',   s:none)
call s:hi('TelescopePreviewNormal', s:fg_dim,   'mantle',   s:none)
call s:hi('TelescopePreviewBorder', 'mantle',   'mantle',   s:none)
call s:hi('TelescopePreviewTitle',  'crust',    s:r_ok,     s:bold)
call s:hi('TelescopeSelection',     s:fg,       'surface0', s:bold)
call s:hi('TelescopeSelectionCaret',s:r_error,  'surface0', s:none)
call s:hi('TelescopeMultiSelection','peach',    'surface0', s:none)
call s:hi('TelescopeMatching',      s:r_match,  '',         s:bold)   " matched chars
call s:hi('TelescopeResultsComment','overlay0', '',         s:italic)
call s:link('TelescopeResultsClass',    'Type')
call s:link('TelescopeResultsFunction', 'Function')
call s:link('TelescopeResultsVariable', 'Identifier')

" -- oil.nvim ('-' to browse) ------------------------------------------------
" oil is an editable buffer, so file operations are shown as pending edits.
" Colour-coding them by verb is what makes "am I about to delete that?" legible.
call s:hi('OilDir',        'blue',      '', s:bold)
call s:hi('OilDirIcon',    'blue',      '', s:none)
call s:hi('OilFile',       s:fg,        '', s:none)
call s:hi('OilLink',       'sapphire',  '', s:none)
call s:hi('OilLinkTarget', 'sky',       '', s:italic)
call s:hi('OilSocket',     'mauve',     '', s:none)
call s:hi('OilHidden',     'overlay0',  '', s:none)
call s:hi('OilCreate',     s:r_added,   '', s:none)
call s:hi('OilCopy',       'sky',       '', s:none)
call s:hi('OilMove',       s:r_changed, '', s:none)
call s:hi('OilChange',     s:r_changed, '', s:none)
call s:hi('OilDelete',     s:r_removed, '', s:none)
call s:hi('OilPurge',      s:r_removed, '', s:bold)
call s:hi('OilTrash',      s:r_removed, '', s:none)
call s:hi('OilTrashSourcePath', 'overlay0', '', s:none)
call s:hi('OilRestore',    s:r_added,   '', s:none)

" -- render-markdown.nvim ----------------------------------------------------
" Headings get a tinted background bar (the *Bg groups). The fg groups colour
" the '#' marker. Rainbow by depth, matching @markup.heading.N in section 7 --
" if you change one, change the other or the two will disagree.
call s:hi('RenderMarkdownH1',   'red',      '', s:bold)
call s:hi('RenderMarkdownH2',   'peach',    '', s:bold)
call s:hi('RenderMarkdownH3',   'yellow',   '', s:bold)
call s:hi('RenderMarkdownH4',   'green',    '', s:bold)
call s:hi('RenderMarkdownH5',   'sapphire', '', s:bold)
call s:hi('RenderMarkdownH6',   'lavender', '', s:bold)
call s:hi('RenderMarkdownH1Bg', 'red',      'surface0', s:bold)
call s:hi('RenderMarkdownH2Bg', 'peach',    'surface0', s:bold)
call s:hi('RenderMarkdownH3Bg', 'yellow',   'surface0', s:bold)
call s:hi('RenderMarkdownH4Bg', 'green',    'surface0', s:bold)
call s:hi('RenderMarkdownH5Bg', 'sapphire', 'surface0', s:bold)
call s:hi('RenderMarkdownH6Bg', 'lavender', 'surface0', s:bold)
call s:hi('RenderMarkdownCode',       '',          'mantle', s:none)  " fenced block bg
call s:hi('RenderMarkdownCodeInline', s:r_string,  'surface0', s:none)
call s:hi('RenderMarkdownCodeBorder', 'overlay0',  'mantle', s:none)
call s:hi('RenderMarkdownBullet',     'peach',     '', s:none)
call s:hi('RenderMarkdownDash',       'overlay0',  '', s:none)
call s:hi('RenderMarkdownQuote',      s:fg_mute,   '', s:italic)
call s:hi('RenderMarkdownTableHead',  'lavender',  '', s:bold)
call s:hi('RenderMarkdownTableRow',   'overlay2',  '', s:none)
call s:hi('RenderMarkdownTableFill',  'overlay0',  '', s:none)
call s:hi('RenderMarkdownLink',       'sapphire',  '', s:underline)
call s:hi('RenderMarkdownMath',       'sapphire',  '', s:italic)
call s:hi('RenderMarkdownSign',       'overlay0',  '', s:none)
call s:hi('RenderMarkdownChecked',    s:r_ok,      '', s:none)
call s:hi('RenderMarkdownUnchecked',  'overlay1',  '', s:none)
call s:hi('RenderMarkdownTodo',       s:r_warn,    '', s:none)
call s:hi('RenderMarkdownSuccess',    s:r_ok,      '', s:none)
call s:hi('RenderMarkdownInfo',       s:r_info,    '', s:none)
call s:hi('RenderMarkdownHint',       s:r_hint,    '', s:none)
call s:hi('RenderMarkdownWarn',       s:r_warn,    '', s:none)
call s:hi('RenderMarkdownError',      s:r_error,   '', s:none)

" -- lazy.nvim (the plugin manager UI) --------------------------------------
call s:link('LazyNormal',      'NormalFloat')
call s:link('LazyH1',          'FloatTitle')
call s:link('LazyButtonActive','PmenuSel')
call s:link('LazyButton',      'Pmenu')
call s:link('LazySpecial',     'Special')

" -- markdown / help / vimdoc (built-in syntax, not plugins) ----------------
call s:hi('markdownH1',           'red',      '', s:bold)
call s:hi('markdownH2',           'peach',    '', s:bold)
call s:hi('markdownH3',           'yellow',   '', s:bold)
call s:hi('markdownCode',         s:r_string, '', s:none)
call s:hi('markdownCodeBlock',    s:r_string, '', s:none)
call s:hi('markdownUrl',          'sapphire', '', s:underline)
call s:hi('markdownLinkText',     'lavender', '', s:none)
call s:hi('helpHyperTextJump',    'sapphire', '', s:underline)
call s:hi('helpSpecial',          'yellow',   '', s:none)
call s:hi('helpHeadline',         s:r_accent, '', s:bold)
call s:hi('helpSectionDelim',     'overlay0', '', s:none)
call s:hi('helpExample',          s:r_string, '', s:none)


" =============================================================================
" 10. Q / K   (kdb+)
" =============================================================================
" vim/syntax/q.vim already links its groups to core groups (qKeyword->Keyword,
" qSymbol->Constant, and so on), so q gets themed by section 6 for free. The
" overrides below exist because q's *literal soup* -- dates, times, timespans,
" symbols, nulls, infinities -- all land on Constant, and telling `2024.01.01`
" apart from `` `sym `` at a glance is most of reading a q script.
"
" Delete this whole section if you'd rather q looked like every other language.

" Temporal literals: one hue for "this is a point or span in time".
call s:hi('qDate',      'teal',   '', s:none)
call s:hi('qMonth',     'teal',   '', s:none)
call s:hi('qTime',      'teal',   '', s:none)
call s:hi('qTimespan',  'teal',   '', s:none)
call s:hi('qTimestamp', 'teal',   '', s:none)
call s:hi('qDatetime',  'teal',   '', s:none)

" Symbols are q's interned strings and are everywhere -- give them their own hue.
call s:hi('qSymbol',    'sky',    '', s:none)
call s:hi('qBoolean',   s:r_number,   '', s:none)

" Nulls and infinities (0N, 0W) are semantically special; treat them as builtin
" constants rather than as plain numbers, so a stray 0N is visible.
call s:hi('qNull',      s:r_builtin,  '', s:bold)
call s:hi('qInfinity',  s:r_builtin,  '', s:bold)

" .z.* / .Q.* internal namespaces, and the \ commands.
call s:hi('qInternalFunction', s:r_builtin, '', s:italic)
call s:hi('qCommand',   s:r_preproc,  '', s:none)
call s:hi('qDML',       s:r_keyword,  '', s:bold)     " select/from/where/by
call s:hi('qIdentifier',s:r_func,     '', s:fn_bold)
call s:hi('qCommentDoc',s:r_comment,  '', 'bold,italic')

" k.vim links to lowercase core group names (constant, statement, function,
" type, number, error, nontext, ...) which vim treats as case-insensitive
" aliases of the section 6 groups -- so k needs no work here beyond the
" 'Variable' group defined in section 6.


" =============================================================================
" 11. TERMINAL COLOURS  (nvim's :terminal, and the built-in terminal in vim 8)
" =============================================================================
" Programs running inside :terminal ask for ANSI colour N; these decide what
" they get. Setting them means git diff, ls --color and ruff output inside nvim
" match the editor, instead of inheriting your terminal profile's palette.
"
" Slot layout: 0-7 normal, 8-15 bright. The bright half is the same hues at
" higher luminance -- except 8 (bright black), which is the muted grey that
" tools use for "dim" text.

if has('nvim')
  let g:terminal_color_0  = s:palette['surface1'][0]
  let g:terminal_color_1  = s:palette['red'][0]
  let g:terminal_color_2  = s:palette['green'][0]
  let g:terminal_color_3  = s:palette['yellow'][0]
  let g:terminal_color_4  = s:palette['blue'][0]
  let g:terminal_color_5  = s:palette['pink'][0]
  let g:terminal_color_6  = s:palette['teal'][0]
  let g:terminal_color_7  = s:palette['subtext1'][0]
  let g:terminal_color_8  = s:palette['surface2'][0]
  let g:terminal_color_9  = s:palette['red'][0]
  let g:terminal_color_10 = s:palette['green'][0]
  let g:terminal_color_11 = s:palette['yellow'][0]
  let g:terminal_color_12 = s:palette['blue'][0]
  let g:terminal_color_13 = s:palette['pink'][0]
  let g:terminal_color_14 = s:palette['teal'][0]
  let g:terminal_color_15 = s:palette['text'][0]
endif


" =============================================================================
" 12. TOOLING
" =============================================================================
" Two commands to make editing this file a loop instead of a guess.
"
"   :MochaPalette   every palette entry, drawn in its own colour, with the hex
"                   and cterm number. Use it to pick a hue for a role.
"   :MochaWhat      the highlight group(s) under the cursor, and what they
"                   resolve to. Works in plain vim; in nvim, :Inspect is
"                   better because it also reports treesitter and LSP.

" Two helper groups per palette entry: the name drawn in the colour (Swatch_),
" and a solid block filled with it (Block_). The block matters -- a dark tier
" like crust is invisible as foreground text but obvious as a filled bar.
for [s:name, s:val] in items(s:palette)
  execute 'highlight MochaSwatch_' . s:name
        \ . ' guifg=' . s:val[0] . ' ctermfg=' . s:val[1]
        \ . ' guibg=NONE ctermbg=NONE gui=bold cterm=bold'
  execute 'highlight MochaBlock_' . s:name
        \ . ' guifg=' . s:val[0] . ' ctermfg=' . s:val[1]
        \ . ' guibg=' . s:val[0] . ' ctermbg=' . s:val[1] . ' gui=NONE cterm=NONE'
endfor
unlet! s:name s:val

function! s:PaletteDemo() abort
  echo 'mocha palette  (name / hex / cterm)'
  for l:n in sort(keys(s:palette))
    " echo starts a new line and echon continues it, so each entry is:
    " one bare echo, then echon fragments. (No trailing " comments on an
    " echo line -- vim reads the quote as the start of a string.)
    echo ''
    execute 'echohl MochaSwatch_' . l:n
    echon printf('%-11s %s %4d  ', l:n, s:palette[l:n][0], s:palette[l:n][1])
    execute 'echohl MochaBlock_' . l:n
    echon '        '
    echohl None
  endfor
endfunction
command! MochaPalette call s:PaletteDemo()

function! s:WhatGroup() abort
  let l:stack = synstack(line('.'), col('.'))
  if empty(l:stack)
    echo 'no syntax group here (treesitter? try :Inspect in nvim)'
    return
  endif
  for l:id in l:stack
    let l:name  = synIDattr(l:id, 'name')
    let l:trans = synIDattr(synID(line('.'), col('.'), 1), 'name')
    let l:final = synIDattr(synIDtrans(l:id), 'name')
    echo printf('%-24s -> %-16s fg=%s', l:name, l:final,
          \ synIDattr(synIDtrans(l:id), 'fg#'))
  endfor
endfunction
command! MochaWhat call s:WhatGroup()

" vim: set fdm=expr fde=getline(v\:lnum)=~'^\"\ =\\{20,}$'?'>1'\:'=' :
