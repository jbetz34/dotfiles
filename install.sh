#!/usr/bin/env bash
#
# dotfiles installer
#
# Design constraints (see README.md):
#   1. NO SUDO. Everything lands in ~/.local. Work boxes won't give you root.
#   2. Prefer statically-linked (musl) binaries so the same install works on
#      RHEL7 (glibc 2.17) as on Ubuntu.
#   3. SYMLINKS, not copies, so ~ and this repo can never drift apart.
#
# Usage:
#   ./install.sh link     # symlink configs into $HOME (safe, backs up)
#   ./install.sh tools    # download binaries into ~/.local/bin
#   ./install.sh all      # both
#
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFIX="${PREFIX:-$HOME/.local}"
BIN="$PREFIX/bin"
OPT="$PREFIX/opt"
STAMP="$(date +%Y%m%d%H%M%S)"

# Pinned versions. Bump deliberately, commit the bump, so rollback is meaningful.
NVIM_VER=v0.12.4
FZF_VER=v0.74.3
FD_VER=v10.4.2
UV_VER=0.12.5
RG_VER=14.1.1
CLANGD_VER=22.1.6

say()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
skip() { printf '    \033[2m·  %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }

have() { command -v "$1" >/dev/null 2>&1; }

# fetch <url> <dest-file>
fetch() { curl -fsSL --retry 3 -o "$2" "$1"; }

# ---------------------------------------------------------------- symlinks --

# link <repo-relative-path> <absolute-target>
link() {
  local src="$DOTFILES/$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
    skip "$dst already linked"
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mv "$dst" "$dst.bak.$STAMP"
    warn "backed up existing $dst -> $dst.bak.$STAMP"
  fi
  ln -s "$src" "$dst"
  say "linked $dst -> $src"
}

do_link() {
  link bash_james        "$HOME/.bash_james"
  link gitconfig         "$HOME/.gitconfig"
  link kubectl_completion "$HOME/.kubectl_completion"
  link inputrc           "$HOME/.inputrc"
  link tmux.conf         "$HOME/.tmux.conf"   # NOTE: install.txt used to say .tmux.comf
  link tmux              "$HOME/.tmux"
  link vimrc             "$HOME/.vimrc"
  link vim               "$HOME/.vim"
  link nvim              "$HOME/.config/nvim"

  # ~/.bashrc is managed by the distro; append our hook once instead of linking.
  if ! grep -q 'bash_james' "$HOME/.bashrc" 2>/dev/null; then
    printf '\n# dotfiles\n[ -f ~/.bash_james ] && . ~/.bash_james\n' >> "$HOME/.bashrc"
    say "appended bash_james hook to ~/.bashrc"
  else
    skip "~/.bashrc already sources bash_james"
  fi
}

# ------------------------------------------------------------------- tools --

install_nvim() {
  if [ -x "$OPT/nvim/bin/nvim" ] && "$OPT/nvim/bin/nvim" --version | head -1 | grep -q "${NVIM_VER#v}"; then
    skip "neovim $NVIM_VER already installed"; return
  fi
  say "installing neovim $NVIM_VER"
  local tmp; tmp="$(mktemp -d)"
  # NOTE: this prebuilt needs glibc >= 2.31. On RHEL7 see README "Working on RHEL7".
  fetch "https://github.com/neovim/neovim/releases/download/$NVIM_VER/nvim-linux-x86_64.tar.gz" "$tmp/nvim.tgz"
  tar -xzf "$tmp/nvim.tgz" -C "$tmp"
  mkdir -p "$OPT"; rm -rf "$OPT/nvim"
  mv "$tmp/nvim-linux-x86_64" "$OPT/nvim"
  ln -sfn "$OPT/nvim/bin/nvim" "$BIN/nvim"
  rm -rf "$tmp"
}

install_fzf() {
  if have fzf; then skip "fzf already installed"; return; fi
  say "installing fzf $FZF_VER"
  local tmp; tmp="$(mktemp -d)"
  fetch "https://github.com/junegunn/fzf/releases/download/$FZF_VER/fzf-${FZF_VER#v}-linux_amd64.tar.gz" "$tmp/fzf.tgz"
  tar -xzf "$tmp/fzf.tgz" -C "$tmp"
  install -m755 "$tmp/fzf" "$BIN/fzf"
  rm -rf "$tmp"
}

install_fd() {
  if have fd; then skip "fd already installed"; return; fi
  say "installing fd $FD_VER (musl static)"
  local tmp d; tmp="$(mktemp -d)"; d="fd-$FD_VER-x86_64-unknown-linux-musl"
  fetch "https://github.com/sharkdp/fd/releases/download/$FD_VER/$d.tar.gz" "$tmp/fd.tgz"
  tar -xzf "$tmp/fd.tgz" -C "$tmp"
  install -m755 "$tmp/$d/fd" "$BIN/fd"
  rm -rf "$tmp"
}

install_rg() {
  if have rg; then skip "ripgrep already installed ($(rg --version | head -1))"; return; fi
  say "installing ripgrep $RG_VER (musl static)"
  local tmp d; tmp="$(mktemp -d)"; d="ripgrep-$RG_VER-x86_64-unknown-linux-musl"
  fetch "https://github.com/BurntSushi/ripgrep/releases/download/$RG_VER/$d.tar.gz" "$tmp/rg.tgz"
  tar -xzf "$tmp/rg.tgz" -C "$tmp"
  install -m755 "$tmp/$d/rg" "$BIN/rg"
  rm -rf "$tmp"
}

install_uv() {
  if have uv; then skip "uv already installed"; return; fi
  say "installing uv $UV_VER (musl static)"
  local tmp d; tmp="$(mktemp -d)"; d="uv-x86_64-unknown-linux-musl"
  fetch "https://github.com/astral-sh/uv/releases/download/$UV_VER/$d.tar.gz" "$tmp/uv.tgz"
  tar -xzf "$tmp/uv.tgz" -C "$tmp"
  install -m755 "$tmp/$d/uv"  "$BIN/uv"
  install -m755 "$tmp/$d/uvx" "$BIN/uvx"
  rm -rf "$tmp"
}

# Python toolchain via uv, so we never touch a system python or need pip.
install_python_lsp() {
  install_uv
  if have ruff; then skip "ruff already installed"; else
    say "installing ruff (lint + format LSP)"; uv tool install -q ruff
  fi
  if have basedpyright; then skip "basedpyright already installed"; else
    say "installing basedpyright (python LSP; bundles its own node)"
    uv tool install -q basedpyright
  fi
}

install_clangd() {
  if have clangd; then skip "clangd already installed"; return; fi
  say "installing clangd $CLANGD_VER (C/C++ LSP)"
  local tmp; tmp="$(mktemp -d)"
  fetch "https://github.com/clangd/clangd/releases/download/$CLANGD_VER/clangd-linux-$CLANGD_VER.zip" "$tmp/clangd.zip"
  # unzip(1) isn't installed and needs root; python3 ships a zip extractor.
  python3 -m zipfile -e "$tmp/clangd.zip" "$tmp/x"
  mkdir -p "$OPT"; rm -rf "$OPT/clangd"
  mv "$tmp/x/clangd_$CLANGD_VER" "$OPT/clangd"
  chmod +x "$OPT/clangd/bin/clangd"
  ln -sfn "$OPT/clangd/bin/clangd" "$BIN/clangd"
  rm -rf "$tmp"
}

# TPM lives outside the repo so tmux plugins are never committed here.
install_tpm() {
  local d="$HOME/.local/share/tmux/plugins/tpm"
  if [ -d "$d/.git" ]; then skip "tpm already installed"; return; fi
  say "installing tpm (tmux plugin manager)"
  mkdir -p "$(dirname "$d")"
  git clone -q --depth 1 https://github.com/tmux-plugins/tpm "$d"
}

do_tools() {
  mkdir -p "$BIN" "$OPT"
  install_nvim
  install_fzf
  install_fd
  install_rg
  install_python_lsp
  install_clangd
  install_tpm
  case ":$PATH:" in
    *":$BIN:"*) ;;
    *) warn "$BIN is not on PATH -- add it in ~/.bash_james" ;;
  esac
}

# -------------------------------------------------------------------- main --

case "${1:-all}" in
  link)  do_link ;;
  tools) do_tools ;;
  all)   do_link; do_tools ;;
  *)     echo "usage: $0 {link|tools|all}" >&2; exit 2 ;;
esac

say "done"
