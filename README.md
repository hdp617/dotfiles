# dotfiles

[chezmoi](https://www.chezmoi.io/) source with **`mode = "symlink"`** in `.chezmoi.toml.tmpl`. The managed checkout usually lives at **`~/.local/share/chezmoi`**.

**Shell:** **Fish** is the intended daily driver (`~/.config/fish/` from **`dot_config/fish/`**). **Zsh** remains available (`dot_zshrc.tmpl`, `~/.zsh` symlink) for compatibility or scripts.

Large trees (`vim/`, `zsh/`, `shell/` under the source dir) are populated by **pinned `archive` externals** in [`.chezmoiexternal.toml`](.chezmoiexternal.toml). External paths are **home-relative** (`.vim/…`, `.zsh/…`, `.shell/…`) so archives land behind the `~/.vim`, `~/.zsh`, and `~/.shell` symlinks into this repo. Versions are pinned in each archive URL; [Renovate](.github/renovate.json) opens PRs to bump them.

## First-time setup

1. Install chezmoi (for example `brew install chezmoi`).
2. Initialize from GitHub (clones into **`~/.local/share/chezmoi`** and writes **`~/.config/chezmoi/chezmoi.toml`**):

   ```bash
   chezmoi init --apply YOUR_GITHUB_USERNAME/dotfiles
   ```

3. On **`chezmoi apply`**, chezmoi clones or updates externals under **`$(chezmoi source-path)`** (see `refreshPeriod` in `.chezmoiexternal.toml`; **`0`** means no periodic `git pull`—use **`chezmoi apply --refresh-externals`** when you want to update plugins).

4. Set Fish as the login shell (after `brew install fish` or your distro package), then:

   ```bash
   grep -q (which fish) /etc/shells; or echo (which fish) | sudo tee -a /etc/shells
   chsh -s (which fish)
   ```

   Optional local overrides: create **`~/.config/fish/config.local.fish`** (sourced at end of `config.fish`).

## Updates

```bash
chezmoi git pull -- --ff-only
chezmoi apply --refresh-externals
```

Or your usual **`dfu`** alias if it wraps the same steps.

## Dependency monitoring

1. **Enable [Renovate](https://github.com/apps/renovate)** on this repository (uses [`.github/renovate.json`](.github/renovate.json)).
   - Bumps pinned chezmoi **archive** URLs in `.chezmoiexternal.toml` (tags and commit SHAs).
   - Bumps `brew` / `cask` / `go` lines in `dot_Brewfile` via Repology and the Go module index.
   - Bumps **GitHub Actions** in workflows.
2. **CI** ([`.github/workflows/dependency-audit.yml`](.github/workflows/dependency-audit.yml)) runs weekly:
   - Downloads pinned externals and scans them with [OSV-Scanner](https://github.com/google/osv-scanner).
   - On macOS, reports outdated Homebrew formulae/casks from `dot_Brewfile` in the job summary.
3. **Locally** after `chezmoi apply --refresh-externals`, inspect checked-out SHAs:
   ```bash
   for d in ~/.vim/pack/vendor/start/* ~/.zsh/plugins/* ~/.shell/plugins/*; do
     [ -d "$d" ] && echo "$d"
   done
   ```

## Layout notes

- **Fish** (`dot_config/fish/`): `conf.d/` snippets (PATH from **`00-chezmoi-path.fish.tmpl`**, env, abbreviations, dircolors, Catppuccin theme, vi bindings, secrets) and **`functions/`** for `dfu`, `load_secret`, `cdgr`, `up`, helpers, plus **`fish_prompt`** / **`fish_right_prompt`** (cwd + `USER at <~/.name>` + `fish_git_prompt`). Not ported from zsh: async right-prompt, `tog` / `vshow` / `vmultiline`.
- **Vim / Zsh / shell externals** ([`.chezmoiexternal.toml`](.chezmoiexternal.toml)): pinned GitHub **archive** downloads for [vim-polyglot](https://github.com/sheerun/vim-polyglot), [vim-go](https://github.com/fatih/vim-go) (`g:polyglot_disabled = ['go']` in `dot_vimrc`), [preservim/nerdtree](https://github.com/preservim/nerdtree), [lightline.vim](https://github.com/itchyny/lightline.vim), [material.vim](https://github.com/kaicataldo/material.vim), [incsearch.vim](https://github.com/haya14busa/incsearch.vim), zsh plugins, and [nordtheme/dircolors](https://github.com/nordtheme/dircolors) under `~/.shell/plugins/nord-dircolors/`.
- **`dot_zshrc.tmpl`**: main zsh init (PATH, Homebrew on macOS, shared `~/.shell` and `~/.zsh` bits). Optional **`~/.zshrc.local`** is sourced last for machine-only overrides (not in this repo).
- **`dot_hammerspoon/`** is skipped on non-macOS via **`.chezmoiignore.tmpl`**.
- **`dotfiles-local/`** is ignored until removed locally.
