function fish_right_prompt
    if test (id -u) -eq 0
        echo -n (set_color red)(whoami)(set_color normal)
    else
        echo -n (set_color magenta)(whoami)(set_color normal)
    end

    echo -n (set_color blue)' at '(set_color normal)
    echo -n (set_color cyan)(_machine_name)(set_color normal)' '

    fish_git_prompt
end
