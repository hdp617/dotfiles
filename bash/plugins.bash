# dircolors
if [[ "$(tput colors)" == "256" ]]; then
  eval "$(dircolors ~/.shell/plugins/nord-dircolors/src/dir_colors)"
fi
