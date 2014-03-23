# vim: set syntax=bash

cddb=$(dirname "$BASH_SOURCE")/bin/cddb
cddb=$(ruby -e "puts File.expand_path(ARGV[0])" "$cddb") || {
  echo "Missing ruby" >&2
}

j() {
  [ $# -gt 1 -a "$1" = "--" ] && {
    shift
    "$cddb" "$@"
    return $?
  }
  dir=$1
  [[ "$dir" ]] || dir=$HOME
  path=$("$cddb" find "$dir")
  cd "$path"
}

_cddb() {
  arg=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=($("$cddb" complete "$arg"))
  return 0
}

complete -F _cddb j
