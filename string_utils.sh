prepend() {
	echo "$2" | sed "s/^/${1}/g" 2>/dev/null \
		|| sed "s/^/${1}/g" "$2" 2>/dev/null \
		|| exit 1
}

# Credit to https://github.com/plasticboy/vim-markdown/issues/126
# result=()
# while read -rd "$sep" i; do
#   array+=("$i")
# done < <(printf '%s%s' "$string" "$sep")

exit_function_error() {
  2<(grep "#> Error:*$1" "$0")
}

#> Error: split_string requires exactly two arguments: An array of delimiters, and a variable in which to store the results.
split_string() {
  [[ $# = 2 ]] || exit_function_error "split_string"
}

is_substring() {
  return $(grep -q "$1" <<< "$2")
  # [[ $2 = *${1}* ]]
  # [[ $2 =~ $1 ]]
}
