# Default to column 1 if 'col' is unset or invalid
# Usage: awktua max [col] <file>
BEGIN {
  FS = ","
  arg = (arg == "" || arg < 1) ? 1 : arg
}

NR>1 {
  val = $arg
  if (val > max) {
    max = val
  }
}

END {
  print max
}
