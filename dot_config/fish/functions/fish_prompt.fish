function fish_prompt
    set -l cmd_status $status

    echo -n (set_color green)(prompt_pwd)(set_color normal)' '

    if test $cmd_status -ne 0
        echo -n (set_color red)'!'(set_color normal)' '
    end

    if test (id -u) -eq 0
        echo -n (set_color red)'>'(set_color normal)' '
    else
        echo -n (set_color magenta)'>'(set_color normal)' '
    end
end
