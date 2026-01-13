#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# 

# Returns a pipe delimited list of file systems that are using more than
# ${__UAC_CONF_EXCLUDE_MOUNT_SIZE} kilobytes. Root file system will always
# be ignored.
#
# Arguments:
#   none
# Returns:
#   pipe delimited string, may be empty
_get_large_file_systems()
{
  [ "${__UAC_CONF_EXCLUDE_MOUNT_SIZE}" -gt 0 ] || return 0
    
  # shellcheck disable=SC2162
  df | while read __gl_dev __gl_size __gl_used __gl_avail __gl_pct __gl_mtpt
  do
    echo "${__gl_used}" | grep -q -E '^[0-9]*$' || continue
    [ "${__gl_used}" -gt "${__UAC_CONF_EXCLUDE_MOUNT_SIZE}" ] && [ "${__gl_mtpt}" != '/' ] && echo "${__gl_mtpt}"
  done | tr \\n \| | sed 's/|$//'
  return 0
}
