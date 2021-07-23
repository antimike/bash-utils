#!/bin/bash
# A utility for setting up a Qubes mininmal template VM to perform various service tasks.

# source $SOURCE_DIR/Shell/bash-utils/logging.sh
# source $SOURCE_DIR/Shell/bash-utils/parse_optsions_v2.sh

# use_logger "$SOURCE_DIR/Shell/bash-utils/test.log"

# Minimal logging setup
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
touch "$__LOGFILE__" && exec 1>"$__LOGFILE__" 2>&1

# Parameters relevant to this script
OUTFILE=

# "Opts" indicate installation options that don't require additional arguments
# Keys represent function names, to be `eval`'d when all CLI arguments have been parsed
# Values represent patterns to match
# @TEST: -u -f -n -p --snap
# @TEST: -e -u -f -n -p --snap
declare -A opts=(
	[basic_utils]="(-u|--utils)"
	[firewall]="(-f|--firewall)"
	[update_and_management]="(-M|--management)"
	[net]="(-n|--net)"
	[usb]="(-U|--usb)"
	[vpn]="(-p|--proxy)"
	[vault]="(-g|--gpg)"
	[misc-security]="(-s|--misc-security)"
	[snap]="(--snap)"
	[thunderbird]="(--thunderbird)"
	[gui]="(-g|--gui)"
)

# "Params" indicate options that take additional CLI arguments, e.g. a filename
# Keys represent global variable names, which will be set upon successfully parsing associated arg(s)
# @TEST: -o $SOURCE_DIR/Shell/bash-utils/test-output.txt
# @TEST: --log=SOURCE_DIR/Shell/bash-utils/test.log
declare -A params=(
	[__OUTFILE__]="(-o|--output)"
	[__LOGFILE__]="(-l|--log)"
)

# "Flags" that indicate actions to take effect *immediately*
# Keys represent patterns to match against CLI args; values will be `eval`'d to yield effects
# @TEST: -v -q -e
declare -A flags=(
	# TODO: Check "(( ))" syntax (i.e., $ needed or not?)
	[(-v|--verbose)]="(( __VERBOSITY__+=1 ))"
	[(-V|--less-verbose)]="(( __VERBOSITY__-=1 ))"
	[(-q|--quiet)]="__VERBOSITY__=$(( __LOGLEVELS__[ERROR] ))"
	[(-Q|--silent)]="__VERBOSITY__=$(( __LOGLEVELS__[SILENT] ))"
	[(-D|--debug)]="__VERBOSITY__=$(( __LOGLEVELS__[DEBUG] ))"
	[(-T|--test)]="__VERBOSITY__=$(( __LOGLEVELS__[TEST] ))"
	[(-e|--except)]="COMMANDS=(${opts[@]}) && __NEGATE_OPTS__="
	[(-h|--help)]="usage"
)


main() {
	while :; do
		case "$1" in
			-a|--all)
				install_all
				;;
		esac
		for key in "${!opts[@]}"; do
			

basic_utils() {
	# Passwordless root
	dnf install qubes-core-agent-passwordless-root -y

	# Editor and basic utils
	dnf install pciutils vim-minimal less psmisc gnome-keyring -y

	# Qubes 4.0 Core Agent
	dnf install qubes-core-agent-dom0-updates qubes-core-agent-qrexec qubes-core-agent-systemd qubes-core-agent-passwordless-root polkit qubes-core-agent-sysvinit -y
}

firewall() {
	# Firewall
	dnf install qubes-core-agent-networking iproute -y
}

update_and_management() {
	# Update VM
	dnf install qubes-core-agent-dom0-updates -y

	# default-mgmt-dvm
	dnf install qubes-core-agent-passwordless-root qubes-mgmt-salt-vm-connector

	# Management / SALT utils
	dnf install qubes-mgmt-salt-vm-connector
}

net() {
	# Net VM
	dnf install qubes-core-agent-networking qubes-core-agent-network-manager NetworkManager-wifi network-manager-applet wireless-tools notification-daemon gnome-keyring polkit @hardware-support -y

	# Network analyzers / debugging
	dnf install tcpdump telnet nmap nmap-ncat -y

	# More Network VM requirements
	dnf install NetworkManager NetworkManager-wifi network-manager-applet wireless-tools dbus-x11 tar tinyproxy iptables -y

	# "Undocumented" network VM requirements
	dnf install which dconf dconf-editor -y
}

usb() {
	# USB VM
	dnf install qubes-usb-proxy qubes-input-proxy-sender
}

vpn() {
	# VPN
	cat <<-MESSAGE
		Run the below command to determine which packages need to be installed:
		> dnf search "NetworkManager VPN plugin"
	MESSAGE
}

vault() {
	# Qubes RPC services
	dnf install qubes-gpg-split qubes-u2f -y

	# Admin / vault tools
	dnf install openssh keepassx openssl gnome-keyring man -y

	# Misc dependencies
	# e.g., needed for the "enter PIN" GPG popup
	dnf install pycairo pinentry-gtk
}

misc_security() {
	# Converters
	dnf install qubes-pdf-converter qubes-img-converter -y

	# Idle shutdown
	dnf install qubes-app-shutdown-idle -y
}

gui() {
	# Lightweight GUI
	dnf install lxterminal dejavu-sans-mono-fonts dejavu-sans-fonts gnome-settings-daemon scite meld thunar thunar-volman ntfs-3g -y

	# Qubes utils for interacting with GUI applications
	dnf install  qubes-desktop-linux-common qubes-menus qubes-core-agent-thunar qubes-core-agent-nautilus -y
}

snap() {
	# Snap
	dnf install qubes-snapd-helper -y
}

thunderbird() {
	# Thunderbird
	dnf install thunderbird-qubes
}
