shopt -s nocasematch  # For case-insensitive globbing

# Variables to "export"

RED="red"; BLACK="black"; GREEN="green"; YELLOW="yellow"; BLUE="blue"; MAGENTA="magenta"; CYAN="cyan"; GRAY="gray"; WHITE="white"

# ANSI escape codes
# Source: https://dev.to/ifenna__/adding-colors-to-bash-scripts-48g4

_get_ansi_escape_code() {

  local _attr_name=$1
  local _key=$2

  case $_attr_name in
    FG|BG)
      echo ${!__${_attr_name}_${__THEME__}_${__TYPE__}__}
      ;;
    MARKUP)
      ;;
    *)
      break
  esac

__THEME__="NORMAL"
__TYPE__="ANSI"

declare -A __FG_NORMAL_ANSI__=(
  [black]=30
  [red]=31
  [green]=32
  [yellow]=33
  [blue]=34
  [magenta]=35
  [cyan]=36
  [gray]=90
  [white]=97
)

declare -A __FG_PASTEL_ANSI__=(
  [red]=91
  [green]=92
  [yellow]=93
  [blue]=94
  [magenta]=95
  [cyan]=96
  [white]=97
)

declare -A __BG_NORMAL_ANSI__=(
  [black]=40
  [red]=41
  [green]=42
  [yellow]=43
  [blue]=44
  [magenta]=45
  [cyan]=46
  [gray]=100
  [white]=107
)

declare -A __BG_PASTEL_ANSI__=(
  [gray]=47
  [red]=101
  [green]=102
  [yellow]=103
  [blue]=104
  [magenta]=105
  [cyan]=106
  [white]=107
)

declare -A __MARKUP_ANSI__=(
  [reset]=0
  [bold]=1
  [faint]=2
  [italics]=3
  [underlined]=4
)

# Using `tput`
# Source: https://linuxhint.com/tput-printf-and-shell-expansions-how-to-create-awesome-outputs-with-bash-scripts/

declare -A __BG_COLORS_TPUT__=(
  black=$(tput setab 0)
  red=$(tput setab 1)
  green=$(tput setab 2)
  yellow=$(tput setab 3)
  blue=$(tput setab 4)
  magenta=$(tput setab 5)
  cyan=$(tput setab 6)
  white=$(tput setab 7)
)

declare -A __FG_COLORS_TPUT__=(
  black=$(tput setaf 0)
  red=$(tput setaf 1)
  green=$(tput setaf 2)
  yellow=$(tput setaf 3)
  blue=$(tput setaf 4)
  magenta=$(tput setaf 5)
  cyan=$(tput setaf 6)
  white=$(tput setaf 7)
)

declare -A __MARKUP_TPUT__=(
  bold=$(tput bold)  
  underline=$(tput smul)  
  endunder=$(tput rmul)   # Exit underline
  reverse=$(tput rev)     # Reverse text
  standout=$(tput smso)   # "Standout" (?)
  endstand=$(tput rmso)   # Exit "standout"
  reset=$(tput sgr0)      # Reset all
)

declare -A __DISPLAY_TPUT__=(
  half=$(tput dim)   
) 

declare -a __CMD_CATEGORIES__=(
  "FG_COLORS"
  "BG_COLORS"
  "MARKUP"
  "DISPLAY"
)

declare -A __CMD_TYPES__=(
  ["$TPUT"]="TPUT"
  ["$ANSI"]="ANSI"
)

_get_cmd() {
  local _type="${__CMD_TYPES__[$TPUT]}"

  # if [[ $# -eq 2 ]]; then
  #   _type=$2
  # fi
  # [[ -n "${__CMD_TYPES__[$2]}"

}

format_out() {
  local msg=$1
  shift
  printf "$@"
}
