#!/bin/bash

#######################################################################################################
# Solution 1: nicerobot's answer on the following SO thread:  
# https://serverfault.com/questions/103501/how-can-i-fully-log-all-bash-scripts-actions
#######################################################################################################

exec 3>&1 4>&2                       # Save file descriptors so that they can be restored later
trap 'exec 2>&4 1>&3' 0 1 2 3 RETURN # Restore file descriptors
                                     # Credit to DavAlPi's comment for the `RETURN` tip
                                     # Usually unnecessary since they should be resstored anyway once the subshell exits
exec 1>"$__LOGFILE__" 2>&1           # Redirect stdout to logfile, and then stderr to stdout
                                     # Note that redirecting stderr to stdout first doesn't work
set -x                               # Credit to dragon951's answer for suggesting this

echo_console() {
	# Prints arguments to console using the above logging setup
	echo $@ >&3
}

printf_console() {
	# Calls `printf` on passed args with the above logging setup
	printf $@ >&3 {
}

return & exit 0		# Credit to DavAlPi's comment on SO thread cited above

#######################################################################################################
# Solution 2: Andry's answer from same thread as #1
# Variation on Solution 1
# I don't really understand everything here...here are Andry's explanations:
#     * There is not enough to just redirect the output because you still have to redirect the inner echo calls both to console and to the file, so the pipe-plus-tee is the only way to split the output stream.
#     * We have to use (...) operator to either redirect each stream into a standalone file or to restore all streams back to the original by separate steps. The second reason because myfoo calls before the self reentrance has to work as is without any additional redirection.
#     * Because the script can be called from a nested script, then we have to redirect the output in a file only once in a top level call. So we use NEST_LVL variable to indicate the nest call level.
#     * Because the redirection can be executed externally irrespective to the script, then we have to explicitly enable the inner redirection by the IMPL_MODE variable.
#     * We have to use date time values to automatically create a new unique log file on each script run.
#######################################################################################################

(( ! IMPL_MODE && ! NEST_LVL )) && {
	export IMPL_MODE=1
	exec 3>&1 4>&2
	trap 'exec 2>&4 1>&3' EXIT HUP INT QUIT RETURN

	[[ ! -e "${SCRIPTS_LOGS_ROOT}/.log" ]] && mkdir "${SCRIPTS_LOGS_ROOT}/.log"

	case $BASH_VERSION in
		# < 4.2
		[123].* | 4.[01] | 4.0* | 4.1[^0-9]*)
			LOG_FILE_NAME_SUFFIX=$(DATE "+%Y'%m'%d_%H'%M'%S''")$(( RANDOM % 1000 ))
			;;
			# >= 4.2
		*)
			printf -v LOG_FILE_NAME_SUFFIX "%(%Y'%m'%d_%H'%M'%S'')T$(( RANDOM % 1000 ))" -1
			;;
	esac

	(
	(
		foo1
		#...
		fooN

		# self script reentrance
		exec $0 "$@"
	) | tee -a "${SCRIPTS_LOGS_ROOT}/.log/${LOG_FILE_NAME_SUFFIX}.myscript.log" 2>&1
	) 1>&3 2>&4

	exit $?
}

(( NEST_LVL++ ))

# Script body

