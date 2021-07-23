get_element_index() {
	local elem="$1"
	local -n arr_ref="$2"
	for (( idx=0; idx<${#arr_ref}; idx++ )); do
		[[ "${arr_ref[idx]}" == "$elem" ]] && echo "$idx" && return 0
	done
	echo -1 && return -1
}
