#!/bin/bash

# Source: https://unix.stackexchange.com/questions/411001/using-case-and-arrays-together-in-bash, Kusalananda
associative_array_contains() {
  return [[ -n "${1[$2]}" ]]
}

# Source: https://unix.stackexchange.com/questions/411001/using-case-and-arrays-together-in-bash, ilkkachu
contains() {
  typeset _x;
  typeset -n _A="$1"
  for _x in "${_A[@]}" ; do
          [ "$_x" = "$2" ] && return 0
  done
  return 1
}
