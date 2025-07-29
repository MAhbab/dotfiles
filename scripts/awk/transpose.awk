# Pivot a CSV file (transpose).
# Usage: awktua transpose <file>

BEGIN {
    OFS = ","
}
{
    for (i = 1; i <= NF; i++) {
        data[NR, i] = $i
        if (i > max_col) max_col = i
    }
    if (NR > max_row) max_row = NR
}
END {
    for (i = 1; i <= max_col; i++) {
        out = data[1, i]
        for (j = 2; j <= max_row; j++) {
            out = out OFS data[j, i]
        }
        print out
    }
}
