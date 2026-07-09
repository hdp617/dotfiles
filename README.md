# dotfiles

[chezmoi](https://www.chezmoi.io/) source with **`mode = "symlink"`** in `.chezmoi.toml.tmpl`. The managed checkout usually lives at **`~/.local/share/chezmoi`**.

**Shell:** **Fish** is the intended daily driver (`~/.config/fish/` from **`dot_config/fish/`**). **Zsh** remains available (`dot_zshrc.tmpl`, `~/.zsh` symlink) for compatibility or scripts.

Large trees (`vim/`, `zsh/`, `shell/` under the source dir) are populated by **`git-repo` externals** in [`.chezmoiexternal.toml`](.chezmoiexternal.toml). External paths are **home-relative** (`.vim/…`, `.zsh/…`, `.shell/…`) so clones land behind the `~/.vim`, `~/.zsh`, and `~/.shell` symlinks into this repo.

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

## Layout notes

- **Fish** (`dot_config/fish/`): primary shell. Modular `conf.d/` snippets:
  - **`00-path.fish.tmpl`** — Homebrew (macOS/Linuxbrew), Go/Rust/chezmoi bin paths, `~/.local/bin`, `~/bin` (does not yet include chezmoi's `~/.bin`; zsh does)
  - **`10-shell-env.fish`** — PIP/Python env mirrors `~/.shell/external.sh`
  - **`20-abbreviations.fish`** — cloud/IaC abbreviations, `ls`/`grep` aliases
  - **`40-theme.fish`** — Catppuccin Macchiato via `fish_config theme`
  - **`50-editor-history.fish`** — `EDITOR=vim`, vi key bindings, large history
  - **`55-git-prompt.fish`** — `fish_git_prompt` color/state variables (used when a custom right prompt calls it)
  - **`60-secrets.fish`** — `load_secret GEMINI_API_KEY`
  - **`functions/`** — `dfu`, `load_secret`, `mcd`, `peek`, `up`
  - Uses Fish **default** left/right prompts today (no custom `fish_prompt` / `fish_right_prompt` yet). Git info appears only if you add a right prompt that calls `fish_git_prompt`.
  - Helpers still **zsh-only** via `~/.shell/aliases.sh`: `cdgr`, `fpr`, `serve`, `jump`, `xin`, `nonascii`, `syspip*`, screen `cd` hack.
  - **Dircolors** (nord) is configured for **zsh only** (`zsh/plugins_after.zsh`), not Fish.
  - Zsh prompt extras not ported: async right-prompt, `tog` / `vshow` / `vmultiline`.
- **Zsh** (`dot_zshrc.tmpl`, `~/.zsh` symlink): legacy/compatibility shell. Sources `~/.shell/{functions,external,aliases}.sh` and `~/.zsh/{settings,prompt,plugins_*}.sh`. Optional **`~/.zshrc.local`** for machine-only overrides.
- **Vim externals** ([`.chezmoiexternal.toml`](.chezmoiexternal.toml)): [vim-polyglot](https://github.com/sheerun/vim-polyglot) for bundled syntax; [vim-go](https://github.com/fatih/vim-go) with **`g:polyglot_disabled = ['go']`** in `dot_vimrc` so Go stays on vim-go. Separate trees for [preservim/nerdtree](https://github.com/preservim/nerdtree), [lightline.vim](https://github.com/itchyny/lightline.vim), [material.vim](https://github.com/kaicataldo/material.vim), [incsearch.vim](https://github.com/haya14busa/incsearch.vim). Dircolors: [nordtheme/dircolors](https://github.com/nordtheme/dircolors) under `~/.shell/plugins/nord-dircolors/` (requires the chezmoi external entry).
- **Bin scripts** (`dot_bin/` → `~/.bin/`): `tmx`, `git-diff-changes` (zsh-specific). Zsh prepends `~/.bin` on PATH; verify Fish PATH includes it if you use Fish daily.
- **`dot_name.tmpl`** → `~/.name`: currently set to `{{ .chezmoi.os }}` (`darwin` / `linux`). Used by tmux status bar and zsh right prompt.
- **`dot_hammerspoon/`** is skipped on non-macOS via **`.chezmoiignore.tmpl`**.
- **Brewfiles**: `dot_Brewfile` → `~/.Brewfile` (full macOS bundle, applied by `run_onchange_install-packages.sh.tmpl` on Darwin). Root `Brewfile` is a smaller reference set, not deployed by chezmoi.
- **Local overrides**: `~/.config/fish/config.local.fish`, `~/.zshrc.local`, `~/.tmux_local.conf`, `~/.gitconfig_local` (templated at init).
