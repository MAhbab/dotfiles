source "$DOTFILES/scripts/parse_command_log.sh"

replay_cd() {
  LOGFILE="$HOME/.zsh_command_log"

  entries=$(get_recent_log_entries "$LOGFILE" 500 true)

  dirs=$(echo "$entries" | awk -F' === ' '!seen[$2]++ { print $2 }')

  selected=$(echo "$dirs" | grep '/' | \
    fzf --ansi --reverse --height=40% \
        --header="Select a recent directory to cd into")

  if [[ -z "$selected" ]]; then
    echo "No directory selected."
    return 1
  fi

  echo "cd \"$selected\""
  cd "$selected" || echo "Failed to cd into $selected"
}

replay_cmd() {
  local LOGFILE="$HOME/.zsh_command_log"
  local MAX_LINES=500

  local entries selected key line timestamp dir cmd exit_status

  entries=$(get_recent_log_entries "$LOGFILE" "$MAX_LINES" true)

  selected=$(echo "$entries" | \
    fzf --with-nth=3 --delimiter=' === ' --ansi --no-sort --reverse --height=40% \
        --header="Enter: copy | Ctrl-R: run here | Ctrl-D: run in original dir" \
        --preview='bash -c "printf \"\033[1;34mDIRECTORY:\033[0m %s\n\033[1;32mTIMESTAMP:\033[0m %s\n\" {2} {1}"' \
        --preview-window=up:3:wrap \
        --expect=enter,ctrl-r,ctrl-d)

  key=$(echo "$selected" | head -n1)
  line=$(echo "$selected" | tail -n1)

  timestamp=$(echo "$line" | awk -F' === ' '{print $1}')
  dir=$(echo "$line" | awk -F' === ' '{print $2}')
  cmd=$(echo "$line" | awk -F' === ' '{print $3}')
  exit_status=$(echo "$line" | awk -F' === ' '{print $4}')

  if [[ -z "$cmd" ]]; then
    echo "No command selected."
    return 1
  fi

  case "$key" in
    enter)
      echo "$cmd"
      echo "$cmd" | pbcopy
      return 0
      ;;
    ctrl-r)
      echo "Running in current directory: $PWD"
      ;;
    ctrl-d)
      echo "Running in original directory: $dir"
      cd "$dir" || { echo "Failed to cd to $dir"; return 1; }
      ;;
  esac

  echo "+ $cmd"
  eval "$cmd"
}
