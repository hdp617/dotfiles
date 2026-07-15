# Pull and apply managed dotfiles. Does not refresh plugin archives — those are
# commit-pinned in .chezmoiexternal.toml; use dfup after bumping pins (or to
# force re-download of the pinned archives).
function dfu
    chezmoi git pull -- --ff-only; or return 1
    chezmoi apply --mode symlink --refresh-externals=never; or return 1
end
