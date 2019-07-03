# dircolors
if [[ "$(tput colors)" == "256" ]]; then
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
    eval "$(dircolors ~/.shell/plugins/dircolors-solarized/dircolors.256dark)"
  fi
fi
