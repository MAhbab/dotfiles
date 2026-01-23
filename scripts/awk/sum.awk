# Default to column 1 if 'col' is unset or invalid
# Usage: awktua sum [col] <file>

BEGIN {
	FS = ","
	arg = (arg == "" || arg < 1) ? 1 : arg
}

NR>1 { sum += $arg }

END { print sum }
