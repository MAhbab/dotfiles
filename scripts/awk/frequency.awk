# Default to column 1 if 'col' is unset or invalid
BEGIN {
  FS = ","
  arg = (arg == "" || arg < 1) ? 1 : arg
}

NR > 1 {
  val = $arg
  counts[val]++
}

END {
  print "value,count"
  for (val in counts) {
    print val "," counts[val]
  }
}
