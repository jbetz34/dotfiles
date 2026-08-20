# dotfiles

tmux + Neovim development environment. Companion to `~/vscode-requirements.md`,
which is the requirements doc this setup is built to satisfy.

## Why this shape

Three constraints drove every decision here:

1. **No sudo.** Work boxes don't hand out root. Everything installs to `~/.local`.
2. **RHEL7 at work** (glibc 2.17). Prefer statically-linked musl binaries so the
   same install works on an ancient enterprise box and on Ubuntu. See
   [Working on RHEL7](#working-on-rhel7) — this is the section that matters most.
3. **Attach from multiple machines.** The session lives on the server as a tmux
   session, not as client-side UI state. This is why VS Code Remote-SSH was
   rejected; see the Verdict section of `vscode-requirements.md`.

## Install

```sh
git clone git@github.com:jbetz34/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh all        # or: ./install.sh link   /   ./install.sh tools
```

`link` symlinks configs into `$HOME`, backing up anything it replaces to
`<file>.bak.<timestamp>`. `tools` downloads pinned binaries into `~/.local/bin`.
Both are idempotent — safe to re-run.

After the first install, inside tmux press `C-Space I` to fetch tmux plugins,
and run `nvim` once to let lazy.nvim bootstrap.

---

## What changed, and why

### Fixed: dotfiles were copies, not symlinks

`install.txt` was a list of destinations that you copied by hand. Every file in
`$HOME` had therefore drifted from the repo independently. Replaced with
`install.sh`, which symlinks — edits in either place are now the same edit.

### Fixed: your tmux config had never been installed

`install.txt` said `tmux.conf ~/.tmux.comf`. Because of that typo, `~/.tmux.conf`
did not exist and **tmux had been running on stock defaults this whole time** —
no `C-Space` prefix, no `Alt+hjkl`, no 10k history, none of the custom status bar.
All of that is live now.

### Installed (all userspace, pinned in `install.sh`)

| Tool | Version | Satisfies |
|---|---|---|
| **neovim** | v0.12.4 | The whole Group 8 block — LSP, telescope, markdown rendering |
| **fzf** | v0.74.3 | Fuzzy finding at the shell |
| **fd** | v10.4.2 | Fast file traversal (musl static) |
| **ripgrep** | 14.1.1 | `easy file/content recursive search` (musl static) |
| **uv** | 0.12.5 | Python tooling without pip, venv, or root (musl static) |
| **ruff** | 0.16.3 | `linting` + `autoformatting` for Python |
| **basedpyright** | 1.39.10 | `hover definitions` + `goto definition` for Python |
| **clangd** | 22.1.6 | `hover definitions` + `goto definition` for C |
| **tpm** | latest | tmux plugin manager |
| **tmux-resurrect / -continuum** | latest | Session survives reboot and `wsl --shutdown` |

`nvim` and `clangd` live in `~/.local/opt/<tool>` with a symlink in `~/.local/bin`,
so upgrades are an atomic directory swap.

### Config changes

**`tmux.conf`**
- `Alt+hjkl` now crosses tmux panes *and* nvim splits with one keystroke
  (vim-tmux-navigator + an `is_vim` detection block). `Alt+Space` is the escape
  hatch if detection guesses wrong.
- Added `C-Space H/J/K/L` to resize panes. `-r` makes them repeatable — hold the
  key instead of re-pressing the leader. This closes the `resize pane = ??` row.
- Added copy-mode-vi bindings: `v` select, `C-v` block select, `y` yank to system
  clipboard, mouse drag-select that doesn't vanish on release.
- Enabled tpm with `tmux-resurrect` + `tmux-continuum`, autosaving every 15 min.
  A bare tmux server dies on reboot; this restores panes *and* their contents.
- `default-terminal` → `tmux-256color`, and `terminal-features` replaces the
  deprecated `terminal-overrides` for RGB and clipboard.
- `TMUX_PLUGIN_MANAGER_PATH` points at `~/.local/share/tmux/plugins/`. **This
  matters**: `~/.tmux` is a symlink into this repo, so default tpm would have
  cloned every plugin's source tree straight into git.
- `focus-events on` so nvim notices focus changes; `detach-on-destroy off` so
  killing the last window switches session instead of dumping you to the shell.

**`nvim/init.lua`** — new, deliberately a *single file*
- Prepends `~/.vim` to `runtimepath`, so nvim reuses `colors/mocha.vim`,
  `syntax/{q,k}.vim` and `ftdetect/`. One colourscheme serves both editors and
  they can't drift.
- `termguicolors` is **on**, because `mocha.vim` is a 24-bit scheme with a
  256-colour fallback — see [Colourscheme](#colourscheme).
- Plugins: vim-tmux-navigator, telescope, oil.nvim, render-markdown.nvim,
  vim-slime, conform.nvim, nvim-lspconfig. lazy.nvim installs them to
  `~/.local/share/nvim`, never into this repo.
- No treesitter plugin. render-markdown uses the markdown parser bundled with
  nvim ≥ 0.10, so **no C compiler is required** — which also means this config
  installs on a box where you can't get `gcc`.
- LSP via nvim 0.11+'s built-in `vim.lsp.enable`, not lspconfig's setup shim.
- A `qls` config block is written but **commented out**, ready for your
  colleague's q language server — see [Adding the q LSP](#adding-the-q-lsp).

**`inputrc`** — new. Binds `Ctrl+Left/Right` word motion across all four escape
sequences terminals actually send, `Alt+Backspace` → `backward-kill-word`, and
puts prefix-filtered history search on Up/Down. This is the Group 3 block of the
requirements doc, made identical on every box you ssh into.

**`vim/colors/mocha.vim`** — new. A Catppuccin-Mocha-flavoured scheme, written
from scratch so it's editable rather than vendored: a palette block, a role
layer, and 300-odd highlight groups covering treesitter, LSP, diagnostics,
telescope, oil, render-markdown and the q/k syntax files. `vimrc` and
`init.lua` now both load it, and the old hard-coded `LineNr`/`CursorLineNr`
overrides in both files are gone — the scheme decides those. Full docs in
[Colourscheme](#colourscheme); the previous `colors/james.vim` stays as the
rollback.

**`.gitignore`** — new. Also untracked `vim/.netrwhist`, which churns on every
directory browse.

---

## Keybindings

### tmux (leader = `C-Space`)

| Key | Action |
|---|---|
| `leader \|` / `leader _` | split vertical / horizontal |
| `leader +` | three-pane layout |
| `Alt+h/j/k/l` | move between panes **and nvim splits** |
| `Alt+Space` | cycle pane (escape hatch) |
| `leader H/J/K/L` | resize pane, repeatable |
| `leader z` | zoom pane |
| `leader x` / `leader &` | kill pane / window |
| `leader [` | copy mode — then `v` select, `y` yank, `/` search |
| `leader C-s` / `leader C-r` | save / restore session manually |
| `leader I` | install plugins |
| `leader r` | reload config |

### nvim (leader = `Space`)

| Key | Action |
|---|---|
| `<leader>ff` / `fg` / `fb` | find files / live grep / buffers |
| `<leader>fd` | diagnostics list |
| `-` | open file browser (oil) at parent dir |
| `gd` / `K` | goto definition / hover |
| `grn` / `gra` / `grr` | rename / code action / references (nvim built-ins) |
| `<leader>s` | send selection or paragraph to the REPL in the last tmux pane |
| `<leader>d` | float line diagnostics |

---

## Working on RHEL7

**Read this before setting up the work box.** RHEL7 ships glibc 2.17, and that
single fact is why VS Code Remote-SSH was ruled out — its server requires glibc
2.28+ since VS Code 1.99. But the same floor affects part of *this* stack too:

| Component | RHEL7 (glibc 2.17)? |
|---|---|
| tmux, tpm, resurrect, continuum | Fine — shell scripts, and tmux is usually packaged |
| `fd`, `ripgrep`, `uv`, `ruff` | **Fine** — statically linked musl, no libc dependency |
| `fzf` | Fine — static Go binary |
| **neovim prebuilt tarball** | **Will not run.** Built against glibc 2.35 |
| **basedpyright** | **Likely fails** — bundles Node 18+, which needs glibc 2.28 |
| clangd | Untested; LLVM targets older glibc, try it before assuming |

Options for Neovim on RHEL7, best first:

1. **conda-forge via micromamba** — userspace, no root, and conda-forge has
   historically targeted CentOS 7. `micromamba install -c conda-forge neovim`.
   Verify the current glibc baseline before relying on it.
2. **Build from source** — reliable but needs a toolchain:
   `devtoolset-9` via SCL (needs root) or a userspace gcc.
3. **Fall back to plain vim.** This is why `init.lua` reuses `~/.vim` rather than
   replacing it: `vimrc` + `colors/mocha.vim` + the q/k syntax files work
   unchanged under stock vim 7.4. You lose LSP and markdown rendering, you keep
   the colourscheme, q syntax, tmux, and every keybinding. The scheme detects
   the missing truecolour support and uses its 256-colour values, so vim 7.4
   looks near-identical — the `has('termguicolors')` guard in `vimrc` is what
   stops `set termguicolors` from erroring out there.

For Python LSP on RHEL7, prefer `ruff server` (static, works) over basedpyright,
and accept lint-and-format without type checking.

## Colourscheme

`vim/colors/mocha.vim` — a Catppuccin-Mocha-flavoured dark theme, hand-rolled so
there's no plugin to fight with. **Plain vim and nvim load the same file**, so
the work box and the laptop can't drift. `:colorscheme mocha`.

The scheme file is the documentation: it has a header explaining how to edit it
and twelve numbered sections you can jump between. The short version:

| Want to change… | Edit |
|---|---|
| a colour's value | §2 PALETTE — `name -> ['#hex', cterm256]` |
| what a colour *means* ("keywords should be blue") | §3 ROLES |
| one specific UI element | §5 EDITOR UI |
| a language's syntax colours | §6 SYNTAX (all editors) or §7 TREESITTER (nvim) |
| q/kdb+ literal colours | §10 Q / K |

Nothing outside §2 mentions a hex value — every group refers to colours by name,
then by role. That's the whole design: `let s:r_string = 'green'` → `'yellow'`
retints strings in every language, including q, at once.

### Options

Set these **before** the `:colorscheme` line (`vimrc` and `init.lua` both have a
commented block in the right place):

| Option | Default | Effect |
|---|---|---|
| `g:mocha_transparent` | `0` | don't paint the background; terminal shows through |
| `g:mocha_italic_comments` | `1` | italic comments |
| `g:mocha_italic_keywords` | `0` | italic keywords too |
| `g:mocha_bold_functions` | `0` | bold function names |
| `g:mocha_dim_inactive` | `1` | dim unfocused splits |
| `g:mocha_contrast` | `'default'` | `'hard'` drops the background to `#11111b` |
| `g:mocha_palette` | — | dict of per-machine colour overrides |

`g:mocha_palette` is the escape hatch for trying values without editing the
scheme — useful for a work-box-only tweak that shouldn't follow you home:

```vim
let g:mocha_palette = {'blue': ['#7aa2f7', 111], 'base': ['#16161e', 234]}
```

### Two commands for editing it

- **`:MochaPalette`** — every colour drawn in itself, with hex and cterm number.
  Use it to pick a hue before assigning it to a role.
- **`:MochaWhat`** — the highlight group(s) under the cursor and what they
  resolve to. In nvim prefer **`:Inspect`**, which also reports the treesitter
  capture and the LSP semantic token.

The loop is: put the cursor on the wrong colour → `:Inspect` → find that group
name in the scheme → change its role → `:colorscheme mocha` to reload. No cache,
no compile step.

### Colour depth

Every group is defined twice — `guifg` (24-bit) and `ctermfg` (256-colour) — so
one file covers every box you ssh into:

| Where | Path taken |
|---|---|
| nvim + tmux (this setup) | 24-bit, exact hex |
| vim 9 in tmux | 24-bit, via the `t_8f`/`t_8b` sequences set in `vimrc` |
| vim 7.4 on RHEL7 | 256-colour fallback, no `termguicolors` |
| 8/16-colour `TERM` | will look wrong — use a `*-256color` TERM |

The cterm numbers deliberately avoid 0–15: those sixteen are whatever your
terminal profile defines, so using them would make the theme change shape from
machine to machine. The greyscale tiers are approximated with 232–255, which
keeps them correctly *ordered* on an old box even though the hue is flatter.

### Contrast

Measured WCAG ratios against the `#1e1e2e` background: text 11.3, every accent
7.1–13.0, comments 5.8. All above the 4.5 threshold for body text. The muted
tiers (`overlay1` 4.4, `overlay0` 3.4) are used for chrome only — line numbers,
borders, invisibles. Ratios drop by roughly a third on top of `CursorLine` and
by half on top of `Visual`; that's why comments sit on `overlay2` rather than
the dimmer `overlay1`. Section 3 of the scheme has the full table.

### Rolling back

`:colorscheme james` — the old scheme is still in `vim/colors/`. To make it
permanent again, change the one `colorscheme` line in `vimrc` and in
`nvim/init.lua`, and set `termguicolors` back to `false` in `init.lua`
(`james.vim` is a cterm scheme and expects that).

## Adding the q LSP

`nvim/init.lua` has a `vim.lsp.config("qls", …)` block, currently commented out.
To enable:

1. Put the server binary on `PATH` (ideally `~/.local/bin`).
2. Set `cmd` to whatever it actually wants — most speak `--stdio`.
3. Uncomment the `vim.lsp.enable({ "qls" })` line below it.
4. `ftdetect/q.vim` already sets `filetype=q`, so it will attach automatically.

That closes the last two Group 8 rows (`hover definitions` and `goto definition`
for q) and removes the final reason to keep VS Code around.

## Config file budget

`vscode-requirements.md` wants total config ≤ 10 files. Current state:

- **Core config — 8 files:** `tmux.conf`, `tmux/status_style_basic.conf`,
  `tmux/status_style_zoom.conf`, `vimrc`, `nvim/init.lua`, `inputrc`,
  `bash_james`, `gitconfig`
- **Theme — 1 file:** `vim/colors/mocha.vim` (shared by vim and nvim)
- **q/k language support — 5 files:** `vim/syntax/{q,k}.vim`,
  `vim/ftdetect/{q,k}.vim`, `vim/ftplugin/k.vim`

`vim/colors/james.vim` is still in the repo but no longer loaded — it's the
rollback path (`:colorscheme james`), not config.

Core config meets the budget. Whether the language-support files count is a call
for you to make — they're language data, not configuration, and they're the
reason a LazyVim distro was rejected (10–30 extra Lua files on its own).

## Rolling back

- **Config:** `git log --oneline` then `git revert <sha>`, and re-run
  `./install.sh link`. Because everything is symlinked, a revert takes effect
  immediately with no re-copying.
- **Your pre-install files:** `install.sh` saved them as `~/*.bak.<timestamp>`.
  Nothing was deleted.
- **Tools:** `rm -rf ~/.local/opt/{nvim,clangd} ~/.local/bin/{nvim,clangd,fd,fzf,rg,uv,uvx}`
  and `uv tool uninstall ruff basedpyright`. Nothing was installed system-wide.
- **Plugins:** `rm -rf ~/.local/share/nvim ~/.local/share/tmux` — both are
  outside this repo and rebuild from scratch on next launch.

## Known gaps

These need `sudo` and are deliberately left undone:

- **`gcc` / `make`** (`sudo apt install build-essential`). Would unlock
  nvim-treesitter parsers for real syntax-aware highlighting of Python and C,
  `telescope-fzf-native` for faster sorting, and building universal-ctags.
- **universal-ctags.** Worth having for q specifically — a `~/.ctags.d/q.ctags`
  regex would give `Ctrl+]` goto-definition on q functions without any LSP.
  Needs a compiler.
- **`clang-format`.** Not in the clangd release zip; C files currently format
  through the LSP rather than conform.nvim.
