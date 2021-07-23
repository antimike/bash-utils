source_dir="$(dirname ${BASH_SOURCE[0]})"
source "${source_dir}/array_utils.sh"
source "${source_dir}/string_utils.sh"
source "${source_dir}/errors.sh"

declare -a parse_order=() # To maintain the parse order
declare -A parsed=()      # Parsed (key, value) pairs (unordered)

declare -A _params=(
  [verbose]=0
  [usage]=":"       # To be run as a function via `exec`
  [options_short]=
  [options_long]=
  [error_handler]=
  [include_help]=1
  [include_verbosity]=1
  [include_verbosity]=1
)


assign_next() {
  "$#" || exit_error "A value is required for option '$2' but was not found"
}



while :; do
  "$#" || break
  case "$1" in
    *=*) 
      process_long_arg "$1"
      ;;
    *)
      process_short_arg "$1"
      ;;
    -v)
      _params[verbose]=$(( _params[verbose] + 1 )) # Increment verbosity by 1
      parse_order+=("verbose")
      ;;
    --verbosity)
      shift
      assign_next "$@" verbose && parse_order+=("verbose")
      ;;
    --)
      shift
      break
      ;;
    *)
      break
  esac

  shift   # Parse next option
done

# parse_options
# =============

# Implementation of a simple options parser.
#
# params (to appear after --):
#   $1: Quoted list of args
#
# options:
#   --include-verbosity, -V
#   --include-help=HELP_FUNC, -h HELP_FUNC
#   --error-handler=ERROR_FUNC, -E ERROR_FUNC
#   --options-long="${OPTIONS[*]}", -O "${OPTIONS[*]}"
#   --options-short="${SHORT_OPTS[*]}", -o "${SHORT_OPTS[*]}"
#   --parse-order=ORDER, -p ORDER
# TODO: Mandatory / non-mandatory opts

parse_options() {
  IFS=' '
  for opt in "$options[@]"; do
    :
  done
}

_parse_options_internal() {

  while :; do
    case "$1" in
      -v|--verbose)
        verbose=$(( verbose + 1 )) # Increment verbosity by 1
        ;;
      # Example of how to parse both long and short options:
      # -f|--file)
      #   if [ "$2" ]; then
      #     file=$2
      #     shift
      #   else
      #     goboom 'ERROR: "--file" requires a nonempty option argument'
      #   fi
      #   ;;
      # --file=?*)
      #   file=${1#*=}
      #   ;;
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

#################################################################################
