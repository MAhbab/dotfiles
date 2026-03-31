alias python="python3"
alias pip="pip3"

# replay functionality
alias rcmd="replay_cmd"
alias rcd="replay_cd"

# neovim configs
alias vim='XDG_CONFIG_HOME=~/dotfiles/config/nvim/main nvim'

# tmux
alias tmux="tmux -f ~/dotfiles/config/tmux/.tmux.conf"

# macOS-like clipboard commands for Linux (Ubuntu)
if [[ "$(uname)" == "Linux" ]]; then
  if command -v xclip &> /dev/null; then
    alias pbcopy="xclip -selection clipboard"
    alias pbpaste="xclip -selection clipboard -o"
  elif command -v xsel &> /dev/null; then
    alias pbcopy="xsel --clipboard --input"
    alias pbpaste="xsel --clipboard --output"
  else
    echo "Warning: xclip or xsel not found. pbcopy/pbpaste aliases not set." >&2
  fi
fi
