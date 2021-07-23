source_dir="$(dirname ${BASH_SOURCE[0]})"
source "${source_dir}/array_utils.sh"
source "${source_dir}/string_utils.sh"
source "${source_dir}/errors.sh"
source "${source_dir}/unit_test.sh"

__START__=
__NAME__="$(basename "$0")"
__VERBOSITY__=0
__DEFAULT_LOGLEVEL__=0
__LOGFILE__="$HOME/template-package-install.log"
__LOGINDENT__=
__LOGDELIMIT__="$(printf '=%.0s' {1..80})"
declare -a __LOGLEVELS__=( SILENT ERROR INFO DEBUG TEST )

# TODO: Expand this function to allow multiple loggers
# TODO: Add individual loggers for all service (library) files
use_logger() {
	log_debug "Checking that file '$1' can be touched"
	(touch "$1") && __LOGFILE__="$1"
	log_debug "Opening logentry"
	open_logentry
}

# Begins new logentry for each script invocation
open_logentry() {
	set_verbosity_global INFO && __DEFAULT_LOGLEVEL__=$__VERBOSITY__
	log_debug "Set verbosity=${__VERBOSITY__}"
	__START__="$(date +%s%N)"			# Time in nanoseconds
	log_debug "Set __START__=${__START__}"
	log_text "$(
		cat <<-LOGHEADER
			$__LOGDELIMIT__
			[$(date)] :: $__START__ :: $__NAME__
			START LOGENTRY
		LOGHEADER
	)"
	__LOGINDENT__="    " && return 0
	log_debug "Exiting"
}

close_logentry() {
	__LOGINDENT__=""
	log_text "$(
		cat <<-LOGFOOTER
			EXECUTION TIME: $(execution_time -c -p 3) ($(execution_time -ns) ns)
			END LOGENTRY
			$__LOGDELIMIT__
		LOGFOOTER
	)"
	return 0
}

# Appends text to logfile with globally-defined indent
log_text() {
	echo "$(prepend "$__LOGINDENT__" "$1")" >> "$__LOGFILE__" && return 0 || return -1
}

set_verbosity_local() {
	# Sets the reference in $2 to the numeric loglevel retrieved based on $1, if an index is found
	local -n ref="$2"
	local idx=$(get_element_index "$1" __LOGLEVELS__)
	(( idx >= 0 )) && ref=$idx && return 0
	return 1
}

set_verbosity_global() {
	local verbosity=$(get_element_index "$1" __LOGLEVELS__) && __VERBOSITY__=$(( verbosity )) \
		&& return 0 || return 1
}

log_debug() {
	if (( __DEBUG__ )); then
		echo "${FUNCNAME[1]}: $1"
	fi
}

report() {
	local prepend=
	local loglevel=$(( __DEFAULT_LOGLEVEL__ ))
	local msg=
	local debug=0
	local include_loglevel=0
	while (( $# )); do
		case "$1" in
			--prepend=*)
				prepend="${1#--prepend=}" && shift && continue
				;;
			-p|--prepend)
				shift && prepend="$1" && shift && continue
				;;
			--include-loglevel=*)
				include_loglevel=$(( ${1#--include_loglevel=} % 2 )) && shift && continue
				;;
			-L|--include-loglevel)
				include_loglevel=$(( (include_loglevel+1) % 2 )) && shift && continue
				;;
			-D|--debug)
				debug=1 && shift && continue
				;;
			-*)
				goboom "$(INTERNAL_ERROR logging.report)"
				;;
		esac
		set_verbosity_local "$1" loglevel && shift && continue
		(( include_loglevel )) && msg="${loglevel}: $1" || msg="$1"
		echo $(prepend "$prepend" "$msg") | tee >(__log_text) \
			| notify --include_loglevel=$include_loglevel
		shift
	done
}

notify() {
	local debug=0
	local prepend=
	local loglevel=$(( __DEFAULT_LOGLEVEL__ ))
	local msg=
	local include_loglevel=0
	while (( $# )); do
		case "$1" in
			--prepend=*)
				prepend="${1#--prepend=}" && shift && continue
				;;
			-p|--prepend)
				shift && prepend="$1" && shift && continue
				;;
			--include-loglevel=*)
				include_loglevel=$(( ${1#--include_loglevel=} % 2 )) && shift && continue
				;;
			-L|--include-loglevel)
				include_loglevel=$(( (include_loglevel+1) % 2 )) && shift && continue
				;;
			-D|--debug)
				debug=1 && shift && continue
				;;
			-*)
				goboom "$(INTERNAL_ERROR logging.notify)"
				;;
		esac
		set_verbosity_local "$1" loglevel && shift && continue
		(( include_loglevel )) && msg="${__LOGLEVELS__[$loglevel]}: ${1}" || msg="$1"
		(( loglevel <= __VERBOSITY__ )) && echo "$(prepend "$prepend" "$msg")"
		shift
	done
}
