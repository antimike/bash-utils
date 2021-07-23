trap 'goboom SIGINT' SIGINT

# Logs error message, reports to user (stdout) if verbosity is high enough, and exits
goboom() {
	echo "ERROR: $1" | tee -a "$__LOGFILE__" && close_logentry && exit 1 || exit -1
}

INTERNAL_ERROR() { printf "%s: Internal error encountered" "$1"; }
UNKNOWN_OPTION() { printf "%s: Unknwon option %s encountered" "$1"; }
UNKNOWN_ERROR() { printf "%s: Unknwon error occurred" "$1"; }
