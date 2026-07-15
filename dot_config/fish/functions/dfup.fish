# Re-download / re-apply plugin archives pinned in .chezmoiexternal.toml.
# Does not float to upstream HEAD — bump commit + sha256 in that file first.
function dfup
    chezmoi apply --mode symlink --refresh-externals=always; or return 1
end
