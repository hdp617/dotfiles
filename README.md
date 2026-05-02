# dotfiles

[chezmoi](https://www.chezmoi.io/) source with **`mode = "symlink"`** in `.chezmoi.toml.tmpl`. The managed checkout usually lives at **`~/.local/share/chezmoi`**. Large trees (`vim/`, `zsh/`, `shell/` under the source dir) are populated by **`git-repo` externals** in [`.chezmoiexternal.toml`](.chezmoiexternal.toml). External paths are **home-relative** (`.vim/…`, `.zsh/…`, `.shell/…`) so clones land behind the `~/.vim`, `~/.zsh`, and `~/.shell` symlinks into this repo.

## First-time setup

1. Install chezmoi (for example `brew install chezmoi`).
2. Initialize from GitHub (clones into **`~/.local/share/chezmoi`** and writes **`~/.config/chezmoi/chezmoi.toml`**):

   ```bash
   chezmoi init --apply YOUR_GITHUB_USERNAME/dotfiles
   ```

3. On **`chezmoi apply`**, chezmoi clones or updates externals under **`$(chezmoi source-path)`** (see `refreshPeriod` in `.chezmoiexternal.toml`; **`0`** means no periodic `git pull`—use **`chezmoi apply --refresh-externals`** when you want to update plugins).

## Updates

```bash
chezmoi git pull -- --ff-only
chezmoi apply --refresh-externals
```

Or your usual **`dfu`** alias if it wraps the same steps.

## Layout notes

- **Vim externals** ([`.chezmoiexternal.toml`](.chezmoiexternal.toml)): [vim-polyglot](https://github.com/sheerun/vim-polyglot) for bundled syntax; [vim-go](https://github.com/fatih/vim-go) with **`g:polyglot_disabled = ['go']`** in `dot_vimrc` so Go stays on vim-go. Separate trees for [preservim/nerdtree](https://github.com/preservim/nerdtree), [lightline.vim](https://github.com/itchyny/lightline.vim), [material.vim](https://github.com/kaicataldo/material.vim), [incsearch.vim](https://github.com/haya14busa/incsearch.vim). Dircolors: [nordtheme/dircolors](https://github.com/nordtheme/dircolors) under `~/.shell/plugins/nord-dircolors/`.
- **`dot_zshrc.tmpl`**: main zsh init (PATH, Homebrew on macOS, shared `~/.shell` and `~/.zsh` bits). Optional **`~/.zshrc.local`** is sourced last for machine-only overrides (not in this repo).
- **`dot_hammerspoon/`** is skipped on non-macOS via **`.chezmoiignore.tmpl`**.
- **`dotfiles-local/`** is ignored until removed locally.
