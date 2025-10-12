" my_terminal_theme.vim
" Custom colorscheme based on provided highlight definitions
" Supports both cterm (256-color) and GUI/termguicolors.

hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "my_terminal_theme"

" --- Custom Highlights ---
hi Added          ctermfg=10 guifg=LimeGreen
hi Bold           term=bold cterm=bold gui=bold
hi BoldItalic     term=bold,italic cterm=bold,italic gui=bold,italic
hi ColorColumn    term=reverse ctermbg=1 guibg=DarkRed
hi Comment        term=bold ctermfg=14 guifg=#80a0ff
hi Conceal        ctermfg=7 ctermbg=242 guifg=LightGrey guibg=DarkGrey
hi Constant       term=underline ctermfg=13 guifg=#ffa0a0
hi CursorColumn   term=reverse ctermbg=242 guibg=Grey40
hi CursorLine     term=underline cterm=underline guibg=Grey40
hi CursorLineNr   term=bold cterm=underline ctermfg=11 gui=bold guifg=Yellow
hi DiffAdd        term=bold ctermbg=4 guibg=DarkBlue
hi DiffChange     term=bold ctermbg=5 guibg=DarkMagenta
hi DiffDelete     term=bold ctermfg=12 ctermbg=6 gui=bold guifg=Blue guibg=DarkCyan
hi DiffText       term=reverse cterm=bold ctermbg=9 gui=bold guibg=Red
hi Directory      term=bold ctermfg=159 guifg=Cyan
hi Error          term=reverse ctermfg=15 ctermbg=9 guifg=White guibg=Red
hi ErrorMsg       term=standout ctermfg=15 ctermbg=1 guifg=White guibg=Red
hi FoldColumn     term=standout ctermfg=14 ctermbg=242 guifg=Cyan guibg=Grey
hi Normal         ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE

" --- Highlight Links (inherit from other groups) ---
hi! link Boolean        Constant
hi! link Character      Constant
hi! link Conditional    Statement
hi! link CurSearch      Search
hi! link CursorLineFold FoldColumn
hi! link CursorLineSign SignColumn
hi! link Debug          Special
hi! link Define         PreProc
hi! link Delimiter      Special
hi! link DiffTextAdd    DiffText
hi! link EndOfBuffer    NonText
hi! link Exception      Statement
hi! link Float          Number

" (Additional common groups for completeness)
hi! link AddedMsg       Added
hi! link Changed        DiffChange
hi! link SignColumn     FoldColumn
hi! link NonText        Comment
hi! link Number         Constant
hi! link Statement      Keyword
hi! link PreProc        Type
hi! link Special        Constant
hi! link Type           Constant

