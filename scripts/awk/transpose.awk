# Pivot a CSV file (transpose).
{
    for (i = 1; i <= NF; i++) {
        a[i, NR] = $i          # Store cell at [column, row]
        if (max_row < NR) max_row = NR
        if (max_col < i)  max_col = i
    }
}
END {
    for (i = 1; i <= max_row; i++) {
        row = ""
        for (j = 1; j <= max_col; j++) {
            sep = (j == 1 ? "" : OFS)
            row = row sep a[j, i]
        }
        print row
    }
}
