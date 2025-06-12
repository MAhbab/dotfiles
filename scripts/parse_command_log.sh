# Usage:
#   source this file
#   then call: get_recent_log_entries

get_recent_log_entries() {
  local logfile="${1:-$HOME/.zsh_command_log}"
  local max_lines="${2:-5000}"
  local exit_only="${3:-true}"
  local blacklist='(rm -rf|gcloud secrets|ssh-keygen|replaylog|^cd )'

  local recent
  if [[ "$exit_only" == "true" ]]; then
    recent=$(tail -rn "$max_lines" "$logfile" | grep "exit=0")
  else
    recent=$(tail -rn "$max_lines" "$logfile")
  fi

  echo "$recent" | \
    grep -Ev "$blacklist" | \
    tail -r | \
    awk -F' \\+\\+ ' '
      {
        key = $2 " ++ " $3
        if (!(key in seen)) {
          seen[key] = 1
          lines[++count] = $0
        }
      }
      END {
        for (i = count; i >= 1; i--) print lines[i]
      }'
}
