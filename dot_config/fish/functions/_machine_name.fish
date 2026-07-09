function _machine_name
    if test -f $HOME/.name
        cat $HOME/.name
    else
        hostname -s
    end
end
