source_dir="$(dirname ${BASH_SOURCE[0]})"
source "${source_dir}/logging.sh"

# Global variables for option and parameter parsing
unset __NEGATE_OPTS__  # When set, this will implicitly accept any options *not* specified on the command line
unset __TO_SET__       # Use to keep track of parsing state
                       # when variable is set, next arg will be treated as an argument to the last option
declare -a COMMANDS=() # Queue of commands to run, built up as options are parsed

get_opts() {
  declare -n opts_ref="$1" && shift
  declare -n params_ref="$1" && shift
  declare -n flags_ref="$1" && shift
  while (( $# )); do
    case "$1" in
      --)
        break
        ;;
      *)
        if [[ -z ${__TO_SET__+x} ]]; then
          get_opt "$1" || get_param "$1" || get_flag "$1" \
            || goboom "$(UNKNOWN_OPTION "$__NAME__" "$1")"
        else
          params_ref[$__TO_SET__]="$1" && unset __TO_SET__ \
            || goboom "$(UNKNOWN_ERROR get_opts)"
        fi
        ;;
    esac
    shift
  done
}

get_opt() {
	for key in "${!opts_ref[@]}"; do
		[[ "$1" =~ "${opts_ref[$key]}" ]] && {
			# TODO: Check syntax
			[[ -z "${__NEGATE_OPTS__+x}" ]] && {		# Check if __NEGATE_OPTS__ is set or not
				COMMANDS+=("$key") && return 0 \
					|| goboom "$(INTERNAL_ERROR get_opt)"
			} || {
				COMMANDS=( "${COMMANDS[@]/$key}" ) && return 0 \
					|| goboom "$(INTERNAL_ERROR get_opt)" # Relies on key / function prefixes being unique
			}
		}
	done
	return 1
}

get_param() {
	for varname in "${!params_ref[@]}"; do
		[[ "$1" =~ "${params_ref[$varname]}" ]] && {
			declare __TO_SET__="$varname" && return 0 \
				|| goboom "$(INTERNAL_ERROR get_param)"
		}
	done
	return 1
}

get_flag() {
	for pattern in "${!flags[@]}"; do
		[[ "$1" =~ "$pattern" ]] && {
			eval "${flags[$pattern]}" && return 0 \
				|| goboom "$(INTERNAL_ERROR get_flag)"
		}
	done
	return 1
}
