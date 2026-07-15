# Pull dotfiles and sync plugin git submodules, then apply.
function dfu
    chezmoi git pull -- --ff-only --recurse-submodules; or return 1
    chezmoi git submodule update --init --recursive; or return 1
    chezmoi apply --mode symlink; or return 1
end
