#!/bin/bash
# 05-07-2021
# Initializes environment for `hub`:
# Decrypts Github PAT and assigns result to environment variable

# Initialize constants
PROGNAME="$(basename $0)"
readonly PROGNAME

# Initialize options  
# Example:
#   opt1=
verbose=0

docstring() {

  # Allows the use of heredocs as "bash docstrings"
  # Example:
  #   docstring FUNC_NAME <<- 'EOF'
  #     Put function documentation here
  #   EOF
  IFS='\n'
  read -r -d '' ${1} || true
}

usage() {

  # Display help message on standard error
  echo "Usage: $PROGNAME" 1>&2
  cat <<- EOF 1>&2
    Usage: $PROGNAME

  EOF
}

clean_up() {

  # Dispose of temporary resources and perform other housekeeping tasks
  exit $1
}

goboom() {

  # Print error message to stderr and exit
  echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
  clean_up 1
}

docstring __PARSE_OPTIONS_DOC__ << 'DOCSTRING'
Usage:
  -h, --help 
    Usage information (help text)
  -v, --verbose 
    adjust verbosity
    Each invocation increments by 1 (default is 0)
  --
    Signals end-of-options in command
    (i.e., immediately ends options parsing)
DOCSTRING
parse_options() {

  # Parse CLI options and assign to global variables initialized above
  while :; do
    case $1 in
      -h|-\?|--help)
        usage
        exit
        ;;
      -v|--verbose)
        verbose=$(( verbose + 1 )) # Increment verbosity by 1
        ;;
      # Example of how to parse both long and short options:
      # -f|--file)
        # if [ "$2" ]; then
          # file=$2
          # shift
        # else
          # goboom 'ERROR: "--file" requires a nonempty option argument'
        # fi
        # ;;
      # --file=?*)
        # file=${1#*=}
        # ;;
      --)                          # End of options sigil
        shift
        break
        ;;
      -?*)                         # Catch-all for unknown options
        printf 'WARNING: Unknown option (ignored): %s\n' "$1" >&2
        ;;
      *)                           # Break when options are fully parsed
        break
    esac

    shift
  done
}

main() {

  # Main program logic and control flow
  :
}

trap clean_up SIGHUP SIGINT SIGTERM
parse_options "$@"
main "$@"
