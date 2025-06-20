{
key = $2 " ++ " $3
if (!(key in seen)) {
  seen[key] = 1
  lines[++count] = $0
}
}
END {
for (i = count; i >= 1; i--) print lines[i]
}
