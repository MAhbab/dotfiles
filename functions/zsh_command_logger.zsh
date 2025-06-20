LOGFILE="$HOME/.zsh_command_log"

preexec() {
  export LAST_COMMAND_START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
  export LAST_COMMAND_PWD="$PWD"
  export LAST_COMMAND="$1"
}

precmd() {
  local exit_status=$?
  local timestamp="$LAST_COMMAND_START_TIME"
  local dir="$LAST_COMMAND_PWD"
  local cmd="$LAST_COMMAND"
  echo "$timestamp === $dir === $cmd === exit=$exit_status" >> "$LOGFILE"
}
