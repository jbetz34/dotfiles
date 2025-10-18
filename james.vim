" Filename: custom_theme.vim
" Description: Custom Vim color scheme generated from provided highlight settings
" Usage: :colorscheme custom_theme

hi clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "james"

" =========================================================================================
" BASIC TEXT & STRUCTURE
" =========================================================================================

" =========================================================================================
" TEXT STYLES
" =========================================================================================

hi Bold           term=bold cterm=bold gui=bold
hi Italic         term=italic cterm=italic gui=italic
hi BoldItalic     term=bold,italic cterm=bold,italic gui=bold,italic
hi Added          ctermfg=10 guifg=LimeGreen
hi Removed        ctermfg=9 guifg=Red
hi Changed        ctermfg=12 guifg=DodgerBlue

" =========================================================================================
" CURSOR & LINE HIGHLIGHTING
" =========================================================================================

hi CursorColumn   term=reverse ctermbg=242 guibg=Grey40
hi CursorLine     term=underline cterm=underline guibg=Grey40
hi LineNr         term=underline ctermfg=11 guifg=Yellow
hi clear LineNrAbove
hi clear LineNrBelow


" =========================================================================================
" SEARCH, MATCH, SPELL
" =========================================================================================

hi Search         term=reverse ctermfg=0 ctermbg=11 guifg=Black guibg=Yellow
hi! link CurSearch Search
hi IncSearch      term=reverse cterm=reverse gui=reverse
hi MatchParen     term=reverse ctermbg=6 guibg=DarkCyan

hi SpellBad       term=reverse ctermbg=9 gui=undercurl guisp=Red
hi SpellCap       term=reverse ctermbg=12 gui=undercurl guisp=Blue
hi SpellLocal     term=underline ctermbg=14 gui=undercurl guisp=Cyan
hi SpellRare      term=reverse ctermbg=13 gui=undercurl guisp=Magenta

" =========================================================================================
" UI ELEMENTS
" =========================================================================================

hi ColorColumn    term=reverse ctermbg=1 guibg=DarkRed
hi Conceal        ctermfg=7 ctermbg=242 guifg=LightGrey guibg=DarkGrey
hi! link CursorLineFold FoldColumn
hi! link CursorLineSign SignColumn
hi Directory      term=bold ctermfg=159 guifg=Cyan
hi! link EndOfBuffer NonText
hi NonText        term=bold ctermfg=12 gui=bold guifg=Blue
hi Ignore         ctermfg=0 guifg=bg
hi Question       term=standout ctermfg=121 gui=bold guifg=Green
hi Todo           term=standout ctermfg=0 ctermbg=11 guifg=Blue guibg=Yellow
hi WarningMsg     term=standout ctermfg=224 guifg=Red
hi Error          term=reverse ctermfg=15 ctermbg=9 guifg=White guibg=Red
hi ErrorMsg       term=standout ctermfg=15 ctermbg=1 guifg=White guibg=Red
hi ModeMsg        term=bold cterm=bold gui=bold
hi MoreMsg        term=bold ctermfg=121 gui=bold guifg=SeaGreen
hi clear MsgArea

" =========================================================================================
" DIFF HIGHLIGHTING
" =========================================================================================

hi DiffAdd        term=bold ctermbg=4 guibg=DarkBlue
hi DiffChange     term=bold ctermbg=5 guibg=DarkMagenta
hi DiffDelete     term=bold ctermfg=12 ctermbg=6 gui=bold guifg=Blue guibg=DarkCyan
hi DiffText       term=reverse cterm=bold ctermbg=9 gui=bold guibg=Red
hi! link DiffTextAdd DiffText

" =========================================================================================
" FOLD & SIGN COLUMNS
" =========================================================================================

hi FoldColumn     term=standout ctermfg=14 ctermbg=242 guifg=Cyan guibg=Grey
hi Folded         term=standout ctermfg=14 ctermbg=242 guifg=Cyan guibg=DarkGrey
hi SignColumn     term=standout ctermfg=14 ctermbg=242 guifg=Cyan guibg=Grey

" =========================================================================================
" POPUPS & MENUS
" =========================================================================================

hi Pmenu          ctermfg=0 ctermbg=13 guibg=Magenta
hi PmenuSbar      ctermbg=248 guibg=Grey
hi PmenuSel       ctermfg=242 ctermbg=0 guibg=DarkGrey
hi PmenuThumb     ctermbg=15 guibg=White

hi! link PmenuExtra Pmenu
hi! link PmenuExtraSel PmenuSel
hi! link PmenuKind Pmenu
hi! link PmenuKindSel PmenuSel
hi! link PmenuMatch Pmenu
hi! link PmenuMatchSel PmenuSel
hi! link PopupSelected PmenuSel
hi! link PopupNotification WarningMsg

" =========================================================================================
" STATUS, TAB, TOOLBAR, SPLITS
" =========================================================================================

hi StatusLine     term=bold,reverse cterm=bold,reverse gui=bold,reverse
hi StatusLineNC   term=reverse cterm=reverse gui=reverse
hi StatusLineTerm term=bold,reverse cterm=bold ctermfg=0 ctermbg=121 gui=bold guifg=bg guibg=LightGreen
hi StatusLineTermNC term=reverse ctermfg=0 ctermbg=121 guifg=bg guibg=LightGreen

hi TabLine        term=underline cterm=underline ctermfg=15 ctermbg=242 gui=underline guibg=DarkGrey
hi TabLineFill    term=reverse cterm=reverse gui=reverse
hi TabLineSel     term=bold cterm=bold gui=bold

hi ToolbarButton  cterm=bold ctermfg=0 ctermbg=7 gui=bold guifg=Black guibg=LightGrey
hi ToolbarLine    term=underline ctermbg=242 guibg=Grey50

hi VertSplit      term=reverse cterm=reverse gui=reverse
hi WildMenu       term=standout ctermfg=0 ctermbg=11 guifg=Black guibg=Yellow

" =========================================================================================
" DIAGNOSTICS, QUICKFIX, ETC.
" =========================================================================================

hi! link QuickFixLine Search
hi! link MessageWindow WarningMsg
hi! link PreInsert Added
hi clear ComplMatchIns
hi clear VisualNOS
hi Visual         ctermfg=0 ctermbg=248 guifg=LightGrey guibg=#575757

" =========================================================================================
" I DON'T KNOW WHAT TO DO WITH THIS YET
" =========================================================================================

hi! link Boolean Constant
hi! link Character Constant
hi Comment        term=bold ctermfg=14 guifg=#80a0ff
hi! link Conditional Statement
hi Constant       term=underline ctermfg=13 guifg=#ffa0a0
hi! link Debug Special
hi! link Define PreProc
hi! link Delimiter Special
hi! link Exception Statement
hi! link Float Number
hi! link Function Identifier
hi Identifier     term=underline cterm=bold ctermfg=14 guifg=#40ffff
hi! link Include PreProc
hi! link Keyword Statement
hi! link Label Statement
hi! link Macro PreProc
hi clear Normal
hi! link Number Constant
hi! link Operator Statement
hi! link PreCondit PreProc
hi PreProc        term=underline ctermfg=81 guifg=#ff80ff
hi! link Repeat Statement
hi Special        term=bold ctermfg=224 guifg=Orange
hi! link SpecialChar Special
hi! link SpecialComment Special
hi SpecialKey     term=bold ctermfg=81 guifg=Cyan
hi Statement      term=bold ctermfg=11 gui=bold guifg=#ffff60
hi! link StorageClass Type
hi! link String Constant
hi! link Structure Type
hi! link Tag Special
hi Title          term=bold ctermfg=225 gui=bold guifg=Magenta
hi Type           term=underline ctermfg=121 gui=bold guifg=#60ff60
hi! link Typedef Type
hi Underlined     term=underline cterm=underline ctermfg=81 gui=underline guifg=#80a0ff

