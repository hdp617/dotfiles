function dfu
    chezmoi git pull -- --ff-only; or return 1
    chezmoi apply --mode symlink --refresh-externals=always
end
