export PATH="/usr/local/bin:$PATH"
export PATH="/opt/homebrew/bin/python3:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/dotfiles/bin:$PATH"

# NVIM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# GCLOUD
# The next line updates PATH for the Google Cloud SDK.
if [ -f '$HOME/google-cloud-sdk/path.zsh.inc' ]; then . '$HOME/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '$HOME/google-cloud-sdk/completion.zsh.inc' ]; then . '$HOME/google-cloud-sdk/completion.zsh.inc'; fi

# PYTHON
# Pyenv Setup
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export PYTHONBREAKPOINT=ipdb.set_trace
export PYTHON3_HOST_PROG="$HOME/.nvim-venv/bin/python" # venv for neovim

# FZF
# fzf scroll preview with alt-j and alt-k
export FZF_DEFAULT_OPTS='--bind=alt-n:preview-down,alt-p:preview-up'

# zsh command logger
[[ -f ~/dotfiles/functions/zsh_command_logger.zsh ]] && source ~/dotfiles/functions/zsh_command_logger.zsh
