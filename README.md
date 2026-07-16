# dotfiles

[![chezmoi](https://github.com/hdp617/dotfiles/actions/workflows/chezmoi.yml/badge.svg)](https://github.com/hdp617/dotfiles/actions/workflows/chezmoi.yml)
[![osv-scan](https://github.com/hdp617/dotfiles/actions/workflows/osv-scan.yml/badge.svg)](https://github.com/hdp617/dotfiles/actions/workflows/osv-scan.yml)

## Install

1. Install [chezmoi](https://www.chezmoi.io/) (for example `brew install chezmoi`).
2. Initialize and apply from GitHub:

   ```bash
   chezmoi init --apply YOUR_GITHUB_USERNAME/dotfiles
   ```

3. Initialize plugin submodules:

   ```bash
   chezmoi git -- submodule update --init --recursive
   ```

4. Set Fish as the login shell (after installing Fish):

   ```bash
   grep -q (which fish) /etc/shells; or echo (which fish) | sudo tee -a /etc/shells
   chsh -s (which fish)
   ```

## Update

```bash
chezmoi git pull -- --ff-only --recurse-submodules
chezmoi git submodule update --init --recursive
chezmoi apply
```

Or run `dfu` (same steps).
