BEGIN {
	FS = ","
}

NR > 1 && ($2 == 0 || $2 == "") && ($8 == 0 || $8 == "") {
	my_list = my_list $1 ","
}

END {
	print my_list
}
