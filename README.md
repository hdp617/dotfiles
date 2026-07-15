# dotfiles

[chezmoi](https://www.chezmoi.io/) source with **`mode = "symlink"`** in `.chezmoi.toml.tmpl`. The managed checkout usually lives at **`~/.local/share/chezmoi`**.

**Shell:** **Fish** is the intended daily driver (`~/.config/fish/` from **`dot_config/fish/`**). **Zsh** remains available (`dot_zshrc.tmpl`, `~/.zsh` symlink) for compatibility or scripts.

Large trees (`vim/`, `zsh/`, `shell/` under the source dir) are symlinked into `$HOME`. Third-party plugins are **git submodules** (see [`.gitmodules`](.gitmodules)) under `vim/pack/vendor/start/` and `zsh/plugins/`, so they appear at `~/.vim/pack/…` and `~/.zsh/plugins/…` through those symlinks.

## First-time setup

1. Install chezmoi (for example `brew install chezmoi`).
2. Initialize from GitHub (clones into **`~/.local/share/chezmoi`** and writes **`~/.config/chezmoi/chezmoi.toml`**):

   ```bash
   chezmoi init --apply YOUR_GITHUB_USERNAME/dotfiles
   ```

3. Initialize plugin submodules in the chezmoi source checkout:

   ```bash
   chezmoi git submodule update --init --recursive
   ```

   Removable leftovers from older layouts: `~/.local/share/vim`, `~/.local/share/zsh/plugins`, and any non-submodule clones under `~/.vim/pack` / `~/.zsh/plugins/zsh-*`.

4. Set Fish as the login shell (after `brew install fish` or your distro package), then:

   ```bash
   grep -q (which fish) /etc/shells; or echo (which fish) | sudo tee -a /etc/shells
   chsh -s (which fish)
   ```

   Optional local overrides: create **`~/.config/fish/config.local.fish`** (sourced at end of `config.fish`).

## Updates

```bash
chezmoi git pull -- --ff-only --recurse-submodules
chezmoi git submodule update --init --recursive
chezmoi apply
```

Or **`dfu`** (same steps).

### Plugin pin maintenance

- **Dependabot** ([`.github/dependabot.yml`](.github/dependabot.yml)) opens weekly PRs for `gitsubmodule` (and GitHub Actions) bumps.
- **OSV-Scanner** ([`.github/workflows/osv-scan.yml`](.github/workflows/osv-scan.yml)) scans the repo and submodule git histories on PRs/pushes and weekly.

## Layout notes

- **Fish** (`dot_config/fish/`): `conf.d/` snippets (PATH from **`00-chezmoi-path.fish.tmpl`**, env, abbreviations, Catppuccin theme, vi bindings, secrets) and **`functions/`** for `dfu`, `load_secret`, `cdgr`, `up`, helpers, plus **`fish_prompt`** / **`fish_right_prompt`** (cwd + `USER at <~/.name>` + `fish_git_prompt`). Not ported from zsh: async right-prompt, `tog` / `vshow` / `vmultiline`.
- **Vim plugins** (git submodules): [vim-polyglot](https://github.com/sheerun/vim-polyglot) for bundled syntax; [vim-go](https://github.com/fatih/vim-go) with **`g:polyglot_disabled = ['go']`** in `dot_vimrc` so Go stays on vim-go. Separate trees for [preservim/nerdtree](https://github.com/preservim/nerdtree), [lightline.vim](https://github.com/itchyny/lightline.vim), [material.vim](https://github.com/kaicataldo/material.vim), [incsearch.vim](https://github.com/haya14busa/incsearch.vim).
- **`dot_zshrc.tmpl`**: main zsh init (PATH, Homebrew on macOS, shared `~/.shell` and `~/.zsh` bits). Optional **`~/.zshrc.local`** is sourced last for machine-only overrides (not in this repo).
- **`dot_hammerspoon/`** is skipped on non-macOS via **`.chezmoiignore.tmpl`**.
- **`dotfiles-local/`** is ignored until removed locally.
