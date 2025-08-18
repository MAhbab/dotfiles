# Usage: dbt compile --select <model> 2>&1 | awktua dbt-trim
# Strips ANSI color codes and filters timestamp-based dbt log lines

{
  # Remove ANSI escape codes
  gsub(/\x1b\[[0-9;]*m/, "")

  # Skip lines that start with timestamps like "20:37:59"
  if ($0 ~ /^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/ || $0 ~ /^Compiled node/) {
    next
  }

  # Otherwise, print the line
  print
}
