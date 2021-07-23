#!/bin/bash
# Get the nesting depth of the current shell
# Credit to loxaxs: https://stackoverflow.com/questions/4511407/how-do-i-know-if-im-running-a-nested-shell

shell_depth_robust() {
	# Correctly deals with `sudo`, but not `su`
	pstree -s $$ | grep sh- -o | wc -l
}

shell_depth_builtin() {
	# Apparently fails to handle `sudo` correctly
	echo $SHLVL
}
