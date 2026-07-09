# dotfiles

[chezmoi](https://www.chezmoi.io/) source with **`mode = "symlink"`** in `.chezmoi.toml.tmpl`. The managed checkout usually lives at **`~/.local/share/chezmoi`**.

**Shell:** **Fish** is the intended daily driver (`~/.config/fish/` from **`dot_config/fish/`**). **Zsh** remains available (`dot_zshrc.tmpl`, `~/.zsh` symlink) for compatibility or scripts.

Large trees (`vim/`, `zsh/`, `shell/` under the source dir) are populated by **pinned `git-repo` externals** in [`.chezmoiexternal.toml`](.chezmoiexternal.toml). External paths are **home-relative** (`.vim/…`, `.zsh/…`, `.shell/…`) so clones land behind the `~/.vim`, `~/.zsh`, and `~/.shell` symlinks into this repo. Plugin versions are pinned via `clone.args = ["--branch", …]`; [Renovate](.github/renovate.json) opens PRs to bump them.

## First-time setup

1. Install chezmoi (for example `brew install chezmoi`).
2. Initialize from GitHub (clones into **`~/.local/share/chezmoi`** and writes **`~/.config/chezmoi/chezmoi.toml`**). You will be prompted for git identity, GitHub username, and a **machine name** (defaults to hostname):

   ```bash
   chezmoi init --apply YOUR_GITHUB_USERNAME/dotfiles
   ```

3. On **`chezmoi apply`**, chezmoi downloads or updates externals under **`$(chezmoi source-path)`** (see `refreshPeriod` in `.chezmoiexternal.toml`; **`0`** means no periodic refresh—use **`chezmoi apply --refresh-externals`** when you want to update plugins).

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
   - Bumps pinned chezmoi **git-repo** branch pins in `.chezmoiexternal.toml`.
   - Bumps `brew` / `cask` / `go` lines in `dot_Brewfile` via Repology and the Go module index.
   - Bumps **GitHub Actions** in workflows.
2. **CI** ([`.github/workflows/dependency-audit.yml`](.github/workflows/dependency-audit.yml)) runs weekly:
   - Clones pinned externals at their configured branches and scans them with [OSV-Scanner](https://github.com/google/osv-scanner).
   - On macOS, reports outdated Homebrew formulae/casks from `dot_Brewfile` in the job summary.
3. **Locally** after `chezmoi apply --refresh-externals`, inspect checked-out plugin trees:
   ```bash
   for d in ~/.vim/pack/vendor/start/* ~/.zsh/plugins/* ~/.shell/plugins/*; do
     [ -d "$d" ] && echo "$d"
   done
   ```

## Layout notes

- **Fish** (`dot_config/fish/`): primary shell. Modular `conf.d/` snippets:
  - **`00-path.fish.tmpl`** — Homebrew (macOS/Linuxbrew), Go/Rust/chezmoi bin paths, `~/.bin`, `~/.local/bin`, `~/bin`
  - **`10-shell-env.fish`** — PIP/Python env mirrors `~/.shell/external.sh`
  - **`20-abbreviations.fish`** — cloud/IaC abbreviations, `ls`/`grep` aliases
  - **`40-theme.fish`** — Catppuccin Macchiato via `fish_config theme`
  - **`50-editor-history.fish`** — `EDITOR=vim`, vi key bindings, large history
  - **`55-git-prompt.fish`** — `fish_git_prompt` color/state variables (used by `fish_right_prompt`)
  - **`60-secrets.fish`** — `load_secret GEMINI_API_KEY`
  - **`functions/`** — `dfu`, `load_secret`, `mcd`, `peek`, `up`, `cdgr`, `fpr`, `serve`, `jump`, `xin`, `nonascii`, `syspip` / `syspip3`
  - **`fish_prompt`** / **`fish_right_prompt`** — cwd + `USER at <~/.name>` + `fish_git_prompt` (aligned with zsh/tmux)
  - Helpers still **zsh-only** via `~/.shell/aliases.sh`: `syspip2`, screen `cd` hack, `tog` / `vshow` / `vmultiline`.
  - **Dircolors** (nord) is configured for **zsh only** (`zsh/plugins_after.zsh`), not Fish.
- **Zsh** (`dot_zshrc.tmpl`, `~/.zsh` symlink): legacy/compatibility shell. Sources `~/.shell/{functions,external,aliases}.sh` and `~/.zsh/{settings,prompt,plugins_*}.sh`. Optional **`~/.zshrc.local`** for machine-only overrides.
- **Vim / Zsh / shell externals** ([`.chezmoiexternal.toml`](.chezmoiexternal.toml)): pinned **git-repo** clones for [vim-polyglot](https://github.com/sheerun/vim-polyglot), [vim-go](https://github.com/fatih/vim-go) (`g:polyglot_disabled = ['go']` in `dot_vimrc`), [preservim/nerdtree](https://github.com/preservim/nerdtree), [lightline.vim](https://github.com/itchyny/lightline.vim), [material.vim](https://github.com/kaicataldo/material.vim), [incsearch.vim](https://github.com/haya14busa/incsearch.vim), zsh plugins, and [nordtheme/dircolors](https://github.com/nordtheme/dircolors) under `~/.shell/plugins/nord-dircolors/`.
- **Bin scripts** (`dot_bin/` → `~/.bin/`): `tmx`, `git-diff-changes`.
- **`dot_name.tmpl`** → `~/.name`: human-readable machine name (prompted at `chezmoi init`, default hostname). Used by tmux status bar and Fish/zsh prompts.
- **`dot_tmux.conf`**: Catppuccin Macchiato theme; status bar shows `@machine_name` from `~/.name`.
- **`dot_hammerspoon/`** is skipped on non-macOS via **`.chezmoiignore.tmpl`**.
- **Brewfiles**: `dot_Brewfile` → `~/.Brewfile` (full macOS bundle, applied by `run_onchange_install-packages.sh.tmpl` on Darwin). Root `Brewfile` is a smaller reference set, not deployed by chezmoi.
- **Local overrides**: `~/.config/fish/config.local.fish`, `~/.zshrc.local`, `~/.tmux_local.conf`, `~/.gitconfig_local` (templated at init).
