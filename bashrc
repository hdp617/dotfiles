# Functions
source ~/.shell/functions.sh

# Allow local customizations in the ~/.shell_local_before file
if [ -f ~/.shell_local_before ]; then
    source ~/.shell_local_before
fi

# Allow local customizations in the ~/.bashrc_local_before file
if [ -f ~/.bashrc_local_before ]; then
    source ~/.bashrc_local_before
fi

# Settings
source ~/.bash/settings.bash

# Bootstrap
source ~/.shell/bootstrap.sh

# External settings
source ~/.shell/external.sh

# Aliases
source ~/.shell/aliases.sh

# Custom prompt
source ~/.bash/prompt.bash

# Plugins
source ~/.bash/plugins.bash

# Allow local customizations in the ~/.shell_local_after file
if [ -f ~/.shell_local_after ]; then
    source ~/.shell_local_after
fi

# Allow local customizations in the ~/.bashrc_local_after file
if [ -f ~/.bashrc_local_after ]; then
    source ~/.bashrc_local_after
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/huypham/Projects/google-cloud-sdk/path.bash.inc' ]; then . '/Users/huypham/Projects/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/huypham/Projects/google-cloud-sdk/completion.bash.inc' ]; then . '/Users/huypham/Projects/google-cloud-sdk/completion.bash.inc'; fi



# Global stuff
export PATH=$HOME/bin:$PATH
export EDITOR=vi

# Homebrew stuff
export PATH=$HOME/homebrew/bin:$PATH
export LD_LIBRARY_PATH=$HOME/homebrew/lib:$LD_LIBRARY_PATH

# Use Sublime Text as the default editor.
export EDITOR="subl -w"

# Add binaries installed via Homebrew to our PATH.
export PATH=$HOME/homebrew/bin:$PATH