# fish_git_prompt appearance (right prompt)
status is-interactive; or exit 0

set -g __fish_git_prompt_showdirtystate true
set -g __fish_git_prompt_showstashstate true
set -g __fish_git_prompt_showuntrackedfiles true
set -g __fish_git_prompt_showupstream informative
set -g __fish_git_prompt_char_stateseparator ' '
set -g __fish_git_prompt_char_dirtystate '*'
set -g __fish_git_prompt_char_stagedstate '+'
set -g __fish_git_prompt_char_untrackedfiles '%'
set -g __fish_git_prompt_color_branch magenta
set -g __fish_git_prompt_color_stagedstate green
set -g __fish_git_prompt_color_dirtystate yellow
set -g __fish_git_prompt_color_invalidstate red
