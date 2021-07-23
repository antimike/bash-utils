#!/bin/bash

# Security stuff
# set -o errexit -o pipefail -o noclobber -o nounset

__NAME__="$(basename $0)"
SCRIPTS_LOGS_ROOT="$(dirname ${BASH_SOURCE[0]})"

(( ! IMPL_MODE && ! NEST_LVL )) && {
	export IMPL_MODE=1
	exec 3>&1 4>&2
	trap 'exec 2>&4 1>&3' EXIT HUP INT QUIT RETURN

	[[ ! -e "${SCRIPTS_LOGS_ROOT}/.log" ]] && mkdir "${SCRIPTS_LOGS_ROOT}/.log"
	LOG_FILE_NAME_SUFFIX="${__NAME__}_$(date +'%Y-%m-%d_%H:%M:%S_')$(( RANDOM % 1000 ))"

	(
	(
		exec $0 "$@"
	) | tee -a "${SCRIPTS_LOGS_ROOT}/.log/${LOG_FILE_NAME_SUFFIX}.log" 2>&1
	) 1>&3 2>&4

	exit $?
}

(( NEST_LVL++ ))

# Script body

d=0
e=0
f=
OPTS=def:
LONGOPTS=debug,except,file:

main() {
	echo "Regular 'echo' call"
	printf '%s\n' "Regular 'printf' call"
	cat <<-EOF
		OPTS:
		    -d|--debug		-->		${d}
				-e|--except		--> 	${e}
				-f|--file			-->		${f}
	EOF
	return & exit 0		# Credit to DavAlPi's comment on SO thread cited above
}

test_getopt_version() {
	! getopt --test > /dev/null
	if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
		echo 'Your version of `getopt` failed the test :('
		exit 1
	fi
}

set_opts() {
	! PARSED=$(getopt --options="$OPTIONS" --longoptions="$LONGOPTS" --name "$__NAME__" -- "$@")
	if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
		exit 2
	fi
	eval set -- "$PARSED"
	while :; do
		case "$1" in
			-d|--debug)
				d=1
				;;
			-e|--except)
				e=1
				;;
			-f|--file)
				f="$2" && shift
				;;
			--)
				break
				;;
			*)
				echo "Unknown error"
				exit 3
				;;
		esac
		shift
	done
}

set_opts "$@" && main
