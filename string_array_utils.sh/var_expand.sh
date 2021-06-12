# var_expand
# ==========
#
# Function to expand $1 into its value that works in both Bash and zsh
# Credit to Tom Hale:
#  https://unix.stackexchange.com/questions/68035/foo-and-zsh 
var_expand() {
  if [ "$#" -ne 1 ] || [ -z "${1-}" ]; then
    printf 'var_expand: expected one nonempty argument\n' >&2;
    return 1;
  fi
  eval printf '%s' "\"\${$1?}\""
}
