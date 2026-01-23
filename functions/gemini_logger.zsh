gemini-log () {
  local dir=~/gemini/chats
  mkdir -p "$dir"

  local ts
  ts=$(date +%s)

  local raw="$dir/$ts.raw.log"
  local time="$dir/$ts.time"
  local flat="$dir/$ts.flat.txt"

  # Optional: open the flat file immediately (comment out if you prefer)
  touch "$flat"
  nvim "$flat" &>/dev/null &

  echo "Recording Gemini session → $raw"

  # Record full interactive session WITH timing
  script -q -t "$time" "$raw" env gemini "$@"

  # Flatten the session after exit
  scriptreplay --timing="$time" "$raw" > "$flat"

  # Strip ANSI from flattened output (safe at this stage)
  sed -E 's/\x1B\[[0-9;?]*[ -/]*[@-~]//g' "$flat" > "$flat.tmp" \
    && mv "$flat.tmp" "$flat"

  echo "Flattened transcript → $flat"
}
