# Chezmoi: modular Fish config lives in conf.d/*.fish
# Optional machine-only overrides (not in this repo)
set -l _local $__fish_config_dir/config.local.fish
test -f $_local; and source $_local
