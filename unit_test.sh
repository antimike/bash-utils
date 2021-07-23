execution_time() {
	# Does not include units---that is the caller's responsibility if desired
	local since=$(( $(date +%s%N) - __START__ ))	# Nanoseconds since start
	local precision=3    # Decimal places to keep after seconds (default is 3, for milliseconds)
                       # Maximum is 9 (nanoseconds)
	__divide_by() { bc <<< "scale=${2}; ${since}/(${1})"; }
	__hours() { __divide_by '10^9*3600' 0; }
	__ms() { __divide_by '10^6' ${precision}; }
	__ns() { echo $since; }
	__s() { __divide_by '10^9' ${precision}; }
	__clock() { 
		# local ret="$(date -u -d@$(( since / 10**9 )) +'%M:%s')"
		local ret="$(( (since / (10**9 * 60)) % 60 )):$(( (since / (10**9)) % 60 ))"
		(( $(__hours) > 0 )) && ret="$(( since / (10**9 * 3600) )):${ret}"
		(( precision > 0 )) && ret+=":$(bc <<< "$(__ms) % 1000")"
		echo "$ret"
	}
	local format=__s
	while (( $# )); do
		case "$1" in
			-s|--seconds)
				format=__s
				;;
			-ms|--milliseconds)
				format=__ms
				;;
			-ns|--nanoseconds)
				format=__ns
				;;
			-c|--clock)
				format=__clock
				;;
			--precision=*)
				precision=$(( ${precision#--precision=} ))
				;;
			-p|--precision)
				shift && precision=$(( $1 ))
				;;
			*)
				goboom "$(INTERNAL_ERROR execution_time)"
		esac
		shift
	done
	(( precision < 0 )) && let precision=0
	(( precision > 9 )) && let precision=9
	$format && return 0
}
