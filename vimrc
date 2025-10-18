" Standard startup options
set number relativenumber expandtab cursorline

" Standard colorschme options
colorscheme james

augroup MyHighlightOverrides
  autocmd!
  autocmd ColorScheme * highlight LineNr ctermfg=Blue guifg=Blue
  autocmd ColorScheme * highlight CursorLine cterm=NONE gui=NONE
  autocmd ColorScheme * highlight CursorLineNr ctermfg=Yellow guifg=Yellow cterm=NONE gui=NONE
augroup END

hi LineNr ctermfg=Blue guifg=Blue
hi CursorLine cterm=NONE gui=NONE
hi CursorLineNr ctermfg=Yellow guifg=Yellow cterm=NONE gui=NONE

" Auto indent for specific filetypes
autocmd FileType yaml set tabstop=2
