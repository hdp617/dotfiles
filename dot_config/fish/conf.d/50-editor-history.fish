status is-interactive; or exit 0

set -gx EDITOR vim
fish_vi_key_bindings

if not set -q fish_history_size
    set -U fish_history_size 1048576
else if test "$fish_history_size" -lt 1048576
    set -U fish_history_size 1048576
end
