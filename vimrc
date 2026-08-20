" Standard startup options
set number relativenumber expandtab cursorline

" ------------------------------------------------------------------ colours --
"
" 24-bit colour, when the vim we're running actually has it. RHEL7's stock
" vim 7.4 does not, and 'set termguicolors' there is a hard error -- hence the
" has() guard. Without it, colors/mocha.vim falls back to its 256-colour
" values automatically, so both paths look near-identical.
"
" t_8f/t_8b are the escape sequences vim uses to *emit* 24-bit colour. Vim only
" knows them for a handful of terminals, and tmux is not one of them, so inside
" tmux they have to be set by hand or truecolour silently does nothing.
" (Neovim needs none of this -- see nvim/init.lua.)
if has('termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" Scheme options must be set BEFORE :colorscheme -- it reads them at load time.
" The full list is documented in section 1 of vim/colors/mocha.vim.
"   let g:mocha_transparent     = 1
"   let g:mocha_italic_keywords = 1
"   let g:mocha_contrast        = 'hard'
colorscheme mocha

" NOTE: this file used to force LineNr/CursorLineNr to hard Blue/Yellow via a
" ColorScheme autocmd. Those overrides are gone -- mocha.vim decides them now
" (search 'LineNr' in it). Add overrides back here only for things you want
" different in vim but not in nvim; anything that should apply to both belongs
" in the scheme itself.

" Auto indent for specific filetypes
autocmd FileType yaml set tabstop=2
