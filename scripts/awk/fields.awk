# Print column names
BEGIN {
  FS = ","
}

NR == 1 {
  for (i = 1; i <= NF; i++) {
    printf("%d: %s\n", i, $i)
  }
  exit
}
