#!/bin/bash

source_dir="$(dirname ${BASH_SOURCE[0]})"
source "${source_dir}/parse_optsions_v2"

set_docstring() {

  # Allows the use of heredocs as "bash docstrings"
  # Example:
  #   docstring FUNC_NAME <<- 'EOF'
  #     Put function documentation here
  #   EOF
  IFS='\n'
  read -r -d '' ${1} || true
}

get_docstring() {

  # Two possible implementations:
  #   1. Using heredoc / sed (cf. SO post)
  #   2. Using ordinary comments

  # Options / args:
  #   --name, -n
  #   --function, -f
  #   --header-only, -H
  #   --title, -t
  #   --left-fence, -l
  #   --right-fence, -r
  sed -e ''
}
