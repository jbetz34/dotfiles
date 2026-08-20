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
- Prepends `~/.vim` to `runtimepath`, so nvim reuses your existing
  `colors/james.vim`, `syntax/{q,k}.vim` and `ftdetect/`. One colourscheme
  serves both editors and they can't drift.
- `termguicolors` is **off** on purpose: `james.vim` is a cterm scheme, so
  letting nvim use the terminal's 16-colour palette is what makes the editor and
  the terminal share a theme (an open row in the requirements matrix).
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
   replacing it: `vimrc` + `colors/james.vim` + the q/k syntax files work
   unchanged under stock vim 7.4. You lose LSP and markdown rendering, you keep
   the colourscheme, q syntax, tmux, and every keybinding.

For Python LSP on RHEL7, prefer `ruff server` (static, works) over basedpyright,
and accept lint-and-format without type checking.

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
- **q/k language support — 6 files:** `vim/colors/james.vim`,
  `vim/syntax/{q,k}.vim`, `vim/ftdetect/{q,k}.vim`, `vim/ftplugin/k.vim`

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
