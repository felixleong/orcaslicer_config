#! /usr/bin/env bash
# Functions
function help_usage() {
  echo >&2 "\
NAME:
  $0 - $0 [<options>] <config-key> <config-value>

DESCRIPTION:
  Modify Orcaslicer process configuration value.

OPTIONS:
  --text, -t                          The configuration value is a text value
  --help, -h                          Show the help message
"
  exit $@
}

# =====================================================================================
# 0. Set variables
VALUE_REGEX='[\d.%]*'
CONFIG_KEY=unset
CONFIG_VALUE=unset

# 1. Check arguments, print usage message if input fails to validate
PARSED_ARGS=$(
  getopt -a -n alphabet -o ht: --long help,text-value -- "$@")
VALID_ARGS=$?
if [ "$VALID_ARGS" != "0" ]; then
  help_usage 1
fi

eval set -- "$PARSED_ARGS"
while :
do
  case "$1" in
    -t | --text) VALUE_REGEX='.*'; shift ;;

    # -- means the end of the arguments; drop this, and break out of the while loop
    --) shift; break ;;
    # If invalid options were passed, then getopt should have reported an error,
    # which we checked as VALID_ARGS when getopt was called...
    -h | --help)   help_usage ;;
    *) echo "Unexpected option: $1 - this should not happen."
       usage ;;
  esac
done

if [ $# -lt 2 ]; then
  echo >&2 "ERROR: $0: Insufficient arguments."
  echo >&2

  help_usage 1
fi

# Set variable
CONFIG_KEY="$1"
CONFIG_VALUE="$2"

cd process
if ! rg -q "${CONFIG_KEY}" *.json; then
  echo >&2 "(EE) Config key not found - ${CONFIG_KEY}: Exit code $?"
  echo >&2

  exit 1
fi


#  '\("'"${CONFIG_KEY}"'": \)"'"${VALUE_REGEX}"'"' \
#  '$1"'"${CONFIG_VALUE}"'"' \

#  '\("initial_layer_speed": "\)[\d\.%]"' \
#  '$1"55"' \

sd \
  '("'${CONFIG_KEY}'": )"'${VALUE_REGEX}'"' \
  '$1"'${CONFIG_VALUE}'"' \
  *.json
echo $?
