function _load_secret_from_file
    set -l env_var_name $argv[1]
    set -l local_file_name (string lower $env_var_name)
    set -l local_file $HOME/.secrets/$local_file_name
    if test -f $local_file
        set -gx $env_var_name (string trim (cat $local_file))
        return 0
    end
    return 1
end

function _load_secret_from_1password
    set -l env_var_name $argv[1]
    set -l op_item_name $argv[2]
    set -l op_vault $argv[3]
    command -q op; or return 1
    set -l op_path op://$op_vault/$op_item_name
    set -l secret_value (op read $op_path 2>/dev/null)
    if test -n "$secret_value"
        set -gx $env_var_name $secret_value
        return 0
    end
    return 1
end

function load_secret
    if test (count $argv) -lt 1
        echo 'Usage: load_secret <ENV_VAR_NAME> [OP_ITEM_NAME] [OP_VAULT_NAME]' >&2
        return 1
    end
    set -l env_var_name $argv[1]
    set -l op_item_name $env_var_name
    set -l op_vault Personal
    test (count $argv) -ge 2; and set op_item_name $argv[2]
    test (count $argv) -ge 3; and set op_vault $argv[3]
    set -q $env_var_name; and set -e $env_var_name
    _load_secret_from_file $env_var_name; and return 0
    _load_secret_from_1password $env_var_name $op_item_name $op_vault; and return 0
    return 1
end
