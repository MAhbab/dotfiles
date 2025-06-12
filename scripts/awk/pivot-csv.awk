# Pivot a CSV file (transpose).
BEGIN {
  FS = OFS = ",";
}
NR == 1 {
  for (i = 1; i <= NF; i++) header[i] = $i;
  next;
}
NR == 2 {
  for (i = 1; i <= NF; i++) print header[i], $i;
}
