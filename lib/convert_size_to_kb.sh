#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006,SC2005,SC2003

# Take a string like "10T" and convert to a number representing kilobytes.
# Valid units are b|c (bytes), k (kilobytes), and M,G,T for mega-, giga-,
# and tera-bytes respectively. Null unit specifier means bytes.
# Arguments:
#   string like "10T"
# Returns:
#   integer number of kilobytes
#   returns zero on any errors
_convert_size_to_kb()
{
  __cs_arg="${1:-0}"

  # return error if format not recognized
  if ! echo "${__cs_arg}" | grep -q -E '^[0-9]*[bckMGT]?$'; then
    echo 0
    return 1
  fi
  
  __cs_number="`echo "${__cs_arg}" | sed 's/[^0-9]//g'`"

  # short circuit for lunatics who enter things like "0T"
  if [ "${__cs_number}" -eq 0 ]; then
      echo 0
      return 0
  fi
  
  __cs_unit="`echo "${__cs_arg}" | tr -d 0-9`"

  # if the unit is "c" or empty, convert the unit to "b"
  [ -n "${__cs_unit}" ] || __cs_unit='b'
  [ "${__cs_unit}" = "c" ] && __cs_unit='b'

  # If they enter a number of bytes less than 1024, expr will round down
  # to zero kilobytes, which is surely not what the user intended.
  # Set exclude size to 1kb.
  [ "${__cs_unit}" = "b" ] && [ "${__cs_number}" -lt 1024 ] && __cs_number=1024

  case "${__cs_unit}" in
    b) echo "`expr "${__cs_number}" / 1024`"
	 ;;
    k) echo "${__cs_number}"
       ;;
    M) echo "`expr "${__cs_number}" \* 1024`"
       ;;
    G) echo "`expr "${__cs_number}" \* 1024 \* 1024`"
       ;;
    T) echo "`expr "${__cs_number}" \* 1024 \* 1024 \* 1024`"
       ;;
    *) echo 0
       return 1
       ;;
  esac
  return 0
}
