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
  # Provides an fzf-based menu to cd into a subdirectory of one of the
  # hard-coded base directories. Directories are sorted by last access time.

  # Hard-coded list of directories to search for subdirectories.
  # Please replace these with your own directories.
  local base_dirs=(
    "~/.dotfiles"
  )

  local search_paths=()
  for dir in "${base_dirs[@]}"; do
    # Only add existing directories to the search path.
    if [[ -d "$dir" ]]; then
      search_paths+=("$dir")
    fi
  done

  if [ ${#search_paths[@]} -eq 0 ]; then
    echo "None of the hard-coded directories exist. Please update replay_cmd in functions/replay.zsh" >&2
    return 1
  fi

  local sorted_dirs
  # Get all subdirectories and sort by last accessed time.
  # The implementation is OS-specific for performance and correctness.
  if [[ "$(uname)" == "Darwin" ]]; then
    # macOS (uses BSD `find` and `stat`).
    # `find` gets all directories, then `stat` prints access time (`%a`) and path (`%N`).
    # `sort -rn` sorts numerically in reverse (most recent first).
    # `sed` removes the timestamp prefix. `s/^[^ ]* //` is used to avoid issues
    # with paths that contain spaces.
    sorted_dirs=$(find "${search_paths[@]}" -type d -exec stat -f '%a %N' {} + | sort -rn | sed 's/^[^ ]* //')
  elif [[ "$(uname)" == "Linux" ]]; then
    # Linux (uses GNU `find`).
    # GNU `find` has a `-printf` option which is very efficient.
    # `%A@` gives last access time as seconds since epoch. `%p` is the file path.
    sorted_dirs=$(find "${search_paths[@]}" -type d -printf '%A@ %p\n' | sort -rn | sed 's/^[^ ]* //')
  else
    echo "Unsupported OS: $(uname). Only macOS and Linux are supported for this function." >&2
    return 1
  fi

  if [[ -z "$sorted_dirs" ]]; then
    echo "No subdirectories found in the specified paths."
    return 1
  fi

  local selected
  selected=$(echo "$sorted_dirs" | fzf --ansi --reverse --height=40% \
      --header="Select a recent directory to cd into")

  if [[ -z "$selected" ]]; then
    echo "No directory selected."
    return 1
  fi

  echo "cd \"$selected\""
  cd "$selected" || echo "Failed to cd into $selected"
}
