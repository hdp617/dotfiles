# dotfiles

[chezmoi](https://www.chezmoi.io/) source with **`mode = "symlink"`** in `.chezmoi.toml.tmpl`. The managed checkout usually lives at **`~/.local/share/chezmoi`**.

**Shell:** **Fish** is the intended daily driver (`~/.config/fish/` from **`dot_config/fish/`**). **Zsh** remains available (`dot_zshrc.tmpl`, `~/.zsh` symlink) for compatibility or scripts.

Large trees (`vim/`, `zsh/`, `shell/` under the source dir) are symlinked into `$HOME`; third-party plugins are **commit-pinned `archive` externals** (SHA-256 checked) in [`.chezmoiexternal.toml`](.chezmoiexternal.toml) under **`~/.local/share/vim`** and **`~/.local/share/zsh/plugins`** (outside those symlinks so chezmoi can verify archives).

## First-time setup

1. Install chezmoi (for example `brew install chezmoi`).
2. Initialize from GitHub (clones into **`~/.local/share/chezmoi`** and writes **`~/.config/chezmoi/chezmoi.toml`**):

   ```bash
   chezmoi init --apply YOUR_GITHUB_USERNAME/dotfiles
   ```

3. On **`chezmoi apply`**, chezmoi downloads pinned plugin archives into **`~/.local/share/…`** (`refreshPeriod = "0"` skips re-download unless forced). To bump a plugin, change its commit URL + `checksum.sha256` in `.chezmoiexternal.toml`, then run **`dfup`** (or `chezmoi apply --refresh-externals=always`). Removable leftovers from the old layout: `~/.vim/pack` and `~/.zsh/plugins/zsh-{completions,syntax-highlighting}`.

4. Set Fish as the login shell (after `brew install fish` or your distro package), then:

   ```bash
   grep -q (which fish) /etc/shells; or echo (which fish) | sudo tee -a /etc/shells
   chsh -s (which fish)
   ```

   Optional local overrides: create **`~/.config/fish/config.local.fish`** (sourced at end of `config.fish`).

## Updates

```bash
chezmoi git pull -- --ff-only
chezmoi apply --refresh-externals=never
```

Or **`dfu`** (same steps). Use **`dfup`** only when re-applying/re-downloading the pinned plugin archives.

## Plugin pin maintenance

Pinned archives in [`.chezmoiexternal.toml`](.chezmoiexternal.toml) are maintained by CI:

- **Scan (OSV):** [`.github/workflows/externals-scan.yml`](.github/workflows/externals-scan.yml) runs on PRs/pushes that touch the pins and weekly; fails if [OSV](https://osv.dev/) reports issues for a pinned commit.
- **Auto-update:** [`.github/workflows/externals-update.yml`](.github/workflows/externals-update.yml) weekly (or manual) bumps each pin to upstream default-branch HEAD, refreshes `checksum.sha256`, re-scans, and opens a PR.

Locally:

```bash
python3 .github/scripts/chezmoi_externals.py list
python3 .github/scripts/chezmoi_externals.py scan --fail-on-vuln
python3 .github/scripts/chezmoi_externals.py update --dry-run
```

## Layout notes

- **Fish** (`dot_config/fish/`): `conf.d/` snippets (PATH from **`00-chezmoi-path.fish.tmpl`**, env, abbreviations, Catppuccin theme, vi bindings, secrets) and **`functions/`** for `dfu`, `dfup`, `load_secret`, `cdgr`, `up`, helpers, plus **`fish_prompt`** / **`fish_right_prompt`** (cwd + `USER at <~/.name>` + `fish_git_prompt`). Not ported from zsh: async right-prompt, `tog` / `vshow` / `vmultiline`.
- **Vim externals** ([`.chezmoiexternal.toml`](.chezmoiexternal.toml), commit-pinned archives): [vim-polyglot](https://github.com/sheerun/vim-polyglot) for bundled syntax; [vim-go](https://github.com/fatih/vim-go) with **`g:polyglot_disabled = ['go']`** in `dot_vimrc` so Go stays on vim-go. Separate trees for [preservim/nerdtree](https://github.com/preservim/nerdtree), [lightline.vim](https://github.com/itchyny/lightline.vim), [material.vim](https://github.com/kaicataldo/material.vim), [incsearch.vim](https://github.com/haya14busa/incsearch.vim).
- **`dot_zshrc.tmpl`**: main zsh init (PATH, Homebrew on macOS, shared `~/.shell` and `~/.zsh` bits). Optional **`~/.zshrc.local`** is sourced last for machine-only overrides (not in this repo).
- **`dot_hammerspoon/`** is skipped on non-macOS via **`.chezmoiignore.tmpl`**.
- **`dotfiles-local/`** is ignored until removed locally.
