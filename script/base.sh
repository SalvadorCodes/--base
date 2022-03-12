#!/usr/bin/env bash


base::titleOf() { set ${*//_/ } ; set ${*,,} ; echo ${*^} ; }

base::printValue() {
    local title=${2:-$(base::titleOf ${1})}
    echo "☑  ${title}: ${!1}" >&2
}

base::printEmpty() {
    local title=${2:-$(base::titleOf ${1})}
    echo "☐  ${title}: ☓" 1>&2
}

# Syntax: setEnv VARIABLE_TO_SET value [Title]
base::setEnv () {
    if [[ ! -z "$2" ]]; then
        export ${1}="${2}"
        base::printValue "${1}" "${3}"
    else
        base::printEmpty "${1}" "${3}"
    fi
}

base::toAbsolutePath() {
    local dir="${1}"
    [[ ! -z "${dir}" ]] && [[ -d ${dir} ]] && cd ${dir} && pwd || echo ""
}

base::toAbsoluteFilePath() {
    local dir=$(dirname ${1})
    local absolutePath=$(base::toAbsolutePath ${dir})
    printf "${absolutePath}/$(basename ${1})"
}

base::unsetAll() {
    unset $(env | awk 'BEGIN { FS="=" } {  print $1 }' | grep -E "${__BASE_ENV_VARS}")
}

base::cleanExit() {
    echo "Cleaning... Will unset all and exit"
    base::unsetAll
    exit 0
}

base::onExit() {
  if [ "$1" != "0" ]; then
    printf "Exit with Error $1 [line $2] "
  else
    echo "Work Completed!"
  fi
  base::cleanExit
}

base::onError() {
  if [ "$1" != "0" ]; then
    echo "Error $1 at line $2"
  else
    echo "Interesting! There was an error, but we're unable to determine the actual error code"
  fi
}

base::obfuscate() {
    local n=3                       # chars to leave unhidden
    local mask="${1:0:${#1}-n}"     # starting from 0, takes <Len>-n chars
    local show="${1:${#1}-n}"       # takes the trailing chars
    printf "%s%s" "${a//?/*}" "$b"  # replaces "mask" by all asterisks
}

base::sourcePath() {
    cd -P "$( dirname "${1}" )" >/dev/null 2>&1 && pwd
}

# Where is the current script physically located?
base::where() {
    local source=${1}
    while [ -h "$source" ]; do
        local dir=$( base::sourcePath "$source" )
        source=$(readlink "$source")
        [[ $source != /* ]] && source=$dir/$source
    done
    echo $( base::sourcePath "$source" )
}

# For testing purposes
base::ping() {
    echo "pong!"
}

echo "Successfully sourced all Base.sh functions"
