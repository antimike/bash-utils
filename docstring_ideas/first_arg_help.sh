#!/bin/bash
# Source: https://stackoverflow.com/questions/20206413/parsing-heredoc-comments-in-bash-script

[ "$1" = "DESCRIPTION" ] && cat <<EOD && exit

Hello, this is the ${1}

This nifty script does x, y and sometimes z
The nice thing is that linebreaks will be preserved.
This makes it a "useful"  'here document'

no problem with 'single' or "double" quotes
nothing matters much except variables

EOD

# Rest of script
