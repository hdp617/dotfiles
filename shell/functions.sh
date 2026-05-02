path_remove() {
    PATH=$(echo -n $PATH | awk -v RS=: -v ORS=: '$0 != "'$1'"' |sed 's/:$//')
}

path_append() {
    path_remove "$1"
    PATH="${PATH:+"$PATH:"}$1"
}

path_prepend() {
    path_remove "$1"
    PATH="$1${PATH:+":$PATH"}"
}

_load_secret_from_file() {
  local env_var_name="$1"
  local local_file_name=$(echo "$env_var_name" | tr '[:upper:]' '[:lower:]')
  local local_file="$HOME/.secrets/${local_file_name}"

  if [ -f "$local_file" ]; then
    export "$env_var_name"=$(cat "$local_file")
    return 0
  fi
  return 1
}

_load_secret_from_1password() {
  local env_var_name="$1"
  local op_item_name="$2"
  local op_vault="$3"

  if ! command -v op &> /dev/null; then
    return 1
  fi

  local op_path="op://${op_vault}/${op_item_name}"
  local secret_value=$(op read "$op_path" 2>/dev/null)

  if [ -n "$secret_value" ]; then
    export "$env_var_name"="$secret_value"
    return 0
  fi
  return 1
}

load_secret() {
  if [ -z "$1" ]; then
    echo "Usage: load_secret <ENV_VAR_NAME> [OP_ITEM_NAME] [OP_VAULT_NAME]" >&2
    return 1
  fi

  local env_var_name="$1"
  local op_item_name="${2:-$env_var_name}"
  local op_vault="${3:-Personal}"

  unset "$env_var_name"
  _load_secret_from_file "$env_var_name" && return 0
  _load_secret_from_1password "$env_var_name" "$op_item_name" "$op_vault" && return 0

  return 1
}
