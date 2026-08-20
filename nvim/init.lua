-- ~/.config/nvim/init.lua
--
-- Deliberately a SINGLE file. vscode-requirements.md has a "total config is 10
-- files or less" requirement, and a LazyVim-style distro costs 10-30 Lua files
-- on its own. Everything below is one screenful per section.
--
-- Reuses ~/.vim wholesale (colourscheme, q/k syntax, ftdetect) so plain vim on a
-- locked-down box and nvim here stay visually identical and never drift.

-------------------------------------------------------------------- runtime --

-- Inherit the existing vim config tree: colors/james.vim, syntax/{q,k}.vim,
-- ftdetect/{q,k}.vim, ftplugin/. One colourscheme, both editors.
vim.opt.runtimepath:prepend(vim.fn.expand("~/.vim"))
vim.opt.runtimepath:append(vim.fn.expand("~/.vim/after"))

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

---------------------------------------------------------------------- opts --

local o = vim.opt
o.number = true
o.relativenumber = true
o.expandtab = true
o.cursorline = true
o.shiftwidth = 4
o.tabstop = 4
o.smartindent = true
o.ignorecase = true
o.smartcase = true
o.undofile = true              -- persistent undo across sessions
o.swapfile = false
o.scrolloff = 6
o.splitright = true
o.splitbelow = true
o.termguicolors = false        -- james.vim is a cterm (16/256 colour) scheme;
                               -- keeping this false makes nvim honour the
                               -- terminal palette, so editor and terminal match.
o.mouse = "a"
o.clipboard = "unnamedplus"    -- yank goes to the system clipboard (OSC52 over ssh)
o.updatetime = 250
o.signcolumn = "yes"

-- yank goes to the Windows/host clipboard even over ssh, via OSC 52
if vim.env.SSH_TTY or vim.env.TMUX then
  vim.g.clipboard = "osc52"
end

vim.cmd.colorscheme("james")

-- Mirror the vimrc highlight overrides so the two editors look the same.
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.cmd([[
      highlight LineNr       ctermfg=Blue   guifg=Blue
      highlight CursorLine   cterm=NONE     gui=NONE
      highlight CursorLineNr ctermfg=Yellow guifg=Yellow cterm=NONE gui=NONE
    ]])
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml", "json", "lua", "markdown" },
  callback = function() vim.opt_local.shiftwidth = 2; vim.opt_local.tabstop = 2 end,
})

------------------------------------------------------------------- plugins --

-- lazy.nvim bootstraps itself into ~/.local/share/nvim, NOT into the dotfiles
-- repo, so plugin source never ends up in git.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
  -- Alt+hjkl moves between tmux panes AND nvim splits with one keystroke.
  -- Requires the matching is_vim block in tmux.conf.
  {
    "christoomey/vim-tmux-navigator",
    init = function() vim.g.tmux_navigator_no_mappings = 1 end,
    keys = {
      { "<M-h>", "<cmd>TmuxNavigateLeft<cr>",  mode = { "n", "t" } },
      { "<M-j>", "<cmd>TmuxNavigateDown<cr>",  mode = { "n", "t" } },
      { "<M-k>", "<cmd>TmuxNavigateUp<cr>",    mode = { "n", "t" } },
      { "<M-l>", "<cmd>TmuxNavigateRight<cr>", mode = { "n", "t" } },
    },
  },

  -- Fuzzy file + content search. Backed by the rg already on PATH.
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "grep (rg)" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",  desc = "help" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>",desc = "diagnostics" },
    },
    opts = { defaults = { layout_strategy = "flex" } },
  },

  -- File tree as an editable buffer. "-" opens the parent dir; edit it like text.
  {
    "stevearc/oil.nvim",
    lazy = false,
    opts = { view_options = { show_hidden = true } },
    keys = { { "-", "<cmd>Oil<cr>", desc = "file browser" } },
  },

  -- In-buffer markdown rendering. Uses the markdown treesitter parser that
  -- ships with nvim >= 0.10, so it needs no C compiler.
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    opts = { completions = { lsp = { enabled = true } } },
  },

  -- Send a visual selection to a REPL running in another tmux pane. This is the
  -- q/python workflow: q in the right pane, source in the left.
  {
    "jpalardy/vim-slime",
    init = function()
      vim.g.slime_target = "tmux"
      vim.g.slime_bracketed_paste = 1
      vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }
    end,
    keys = {
      { "<leader>s", "<Plug>SlimeRegionSend",    mode = "v", desc = "send selection to REPL" },
      { "<leader>s", "<Plug>SlimeParagraphSend", mode = "n", desc = "send paragraph to REPL" },
    },
  },

  -- Format on save, per-filetype, without routing through the LSP.
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = {
      formatters_by_ft = {
        python = { "ruff_format", "ruff_organize_imports" },
        lua = { "stylua" },
      },
      format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
    },
  },

  { "neovim/nvim-lspconfig" },
}, {
  install = { colorscheme = { "james" } },
  change_detection = { notify = false },
})

----------------------------------------------------------------------- lsp --

-- nvim >= 0.11 has vim.lsp.config/enable built in; nvim-lspconfig only supplies
-- the per-server defaults. Servers are installed by install.sh into ~/.local/bin.
vim.lsp.enable({ "ruff", "basedpyright", "clangd" })

-- q/kdb+ language server.
-- There is no mainstream public q LSP, so this is wired up but left disabled.
-- To turn it on: put the binary on PATH, set cmd below, and uncomment the enable.
vim.lsp.config("qls", {
  cmd = { "qls", "--stdio" },
  filetypes = { "q" },
  root_markers = { ".git" },
  settings = {},
})
-- vim.lsp.enable({ "qls" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    -- nvim 0.11+ already binds K (hover), grn (rename), gra (code action),
    -- grr (references), gri (implementation). Only gd is missing.
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "goto definition" })
    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

vim.diagnostic.config({
  virtual_text = { prefix = "*" },
  severity_sort = true,
  float = { border = "rounded" },
})

------------------------------------------------------------------- keymaps --

local map = vim.keymap.set
map("n", "<leader>w", "<cmd>write<cr>",  { desc = "write" })
map("n", "<leader>q", "<cmd>quit<cr>",   { desc = "quit" })
map("n", "<Esc>",     "<cmd>nohlsearch<cr>", { desc = "clear search highlight" })
map("t", "<Esc><Esc>","<C-\\><C-n>",     { desc = "leave terminal mode" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "line diagnostics" })

-- Keep the cursor put when joining / centre the view when jumping.
map("n", "J", "mzJ`z")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
