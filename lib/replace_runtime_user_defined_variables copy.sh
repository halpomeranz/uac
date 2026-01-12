#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Replace runtime and user-defined variables.
#   string input: string containing multiple %var% or %var=default_value% variables
# Returns:
#   string: input string with all runtime and user-defined variables expanded
#           Runtime and user-defined variables have the form:
#             %var%                 replaced by value of var (empty if unset)
#             %var=default_value%   replaced by value of var, or default if var is unset

_replace_runtime_user_defined_variables()
{
  __uv_input="${1:-}"
  __uv_output="${__uv_input}"
  
  while true; do
    # get user defined variable with or without default value
    __uv_user_defined_variable=`printf "%s" "${__uv_output}" \
      | sed -n 's|^[^%]*%\([A-Za-z_][A-Za-z0-9_]*\)=\([^%]*\)%.*|%\1=\2%|p'`

    # replace %var% with %var=% when no default value was specified
    if [ -z "${__uv_user_defined_variable}" ]; then
      __uv_user_defined_variable=`printf "%s" "${__uv_output}" \
        | sed -n 's|^[^%]*%\([A-Za-z_][A-Za-z0-9_]*\)\([^%]*\)%.*|%\1=%|p'`
    fi

    printf "%s\n" "DEBUG: __uv_user_defined_variable: ${__uv_user_defined_variable}" >&2
    if [ -n "${__uv_user_defined_variable}" ]; then
      __uv_var_name=`printf "%s" "${__uv_user_defined_variable}" \
        | sed 's|^%\([A-Za-z_][A-Za-z0-9_]*\)=.*%|\1|'`
      __uv_var_default_value=`printf "%s" "${__uv_user_defined_variable}" \
        | sed 's|^%[A-Za-z_][A-Za-z0-9_]*=\(.*\)%|\1|'`
      __uv_user_defined_variable=`printf "%s" "${__uv_user_defined_variable}" \
        | sed 's|=%$|%|'`
    else
      printf "%s\n" "DEBUG: ENTROU" >&2
      case "${__uv_output}" in
        *%*)
          printf "%s\n" "DEBUG: __uv_output: ${__uv_output}" >&2
          __uv_output=`printf "%s" "${__uv_output}" | sed -e 's|%|#_PERCENTAGE_#|'`
          printf "%s\n" "DEBUG: __uv_output: ${__uv_output}" >&2
          continue
          ;;
        *)
          # no more user-defined variables
          break
          ;;
      esac
    fi

    if [ "${__uv_var_name}" = "hostname" ]; then
      __uv_output=`printf "%s" "${__uv_output}" \
        | sed -e "s|${__uv_user_defined_variable}|${__UAC_HOSTNAME:-}|"`
      continue
    elif [ "${__uv_var_name}" = "os" ]; then
      __uv_output=`printf "%s" "${__uv_output}" \
        | sed -e "s|${__uv_user_defined_variable}|${__UAC_OPERATING_SYSTEM:-}|"`
      continue
    elif [ "${__uv_var_name}" = "timestamp" ]; then
      __uv_output=`printf "%s" "${__uv_output}" \
        | sed -e "s|${__uv_user_defined_variable}|${__UAC_TIMESTAMP:-}|"`
      continue
    elif [ "${__uv_var_name}" = "uac_directory" ]; then
      __uv_output=`printf "%s" "${__uv_output}" \
        | sed -e "s|${__uv_user_defined_variable}|${__UAC_DIR:-}|"`
      continue
    elif [ "${__uv_var_name}" = "mount_point" ]; then
      __uv_output=`printf "%s" "${__uv_output}" \
        | sed -e "s|${__uv_user_defined_variable}|${__UAC_MOUNT_POINT:-}|"`
      continue
    elif [ "${__uv_var_name}" = "temp_directory" ]; then
      __uv_output=`printf "%s" "${__uv_output}" \
        | sed -e "s|${__uv_user_defined_variable}|${__UAC_TEMP_DATA_DIR:-}/tmp|"`
      continue
    elif [ "${__uv_var_name}" = "artifacts_output_directory" ]; then
      __uv_output=`printf "%s" "${__uv_output}" \
        | sed -e "s|${__uv_user_defined_variable}|${__UAC_ARTIFACTS_OUTPUT_DIR:-}|"`
      continue
    elif [ "${__uv_var_name}" = "non_local_mount_points" ]; then
      __uv_output=`printf "%s" "${__uv_output}" \
        | sed -e "s'${__uv_user_defined_variable}'${__UAC_EXCLUDE_MOUNT_POINTS:-}'"`
      continue
    elif [ "${__uv_var_name}" = "start_date" ]; then
      if [ -n "${__UAC_START_DATE:-}" ]; then
        __uv_output=`printf "%s" "${__uv_output}" \
          | sed -e "s|${__uv_user_defined_variable}|${__UAC_START_DATE}|"`
      else
        __uv_output=`printf "%s" "${__uv_output}" \
          | sed -e "s|${__uv_user_defined_variable}|1970-01-01|"`
      fi
      continue
    elif [ "${__uv_var_name}" = "start_date_epoch" ]; then
      if [ -n "${__UAC_START_DATE_EPOCH:-}" ]; then
        __uv_output=`printf "%s" "${__uv_output}" \
          | sed -e "s|${__uv_user_defined_variable}|${__UAC_START_DATE_EPOCH}|"`
      else
        __uv_output=`printf "%s" "${__uv_output}" \
          | sed -e "s|${__uv_user_defined_variable}|1|"`
      fi
      continue
    elif [ "${__uv_var_name}" = "end_date" ]; then
      if [ -n "${__UAC_END_DATE:-}" ]; then
        __uv_output=`printf "%s" "${__uv_output}" \
          | sed -e "s|${__uv_user_defined_variable}|${__UAC_END_DATE:-}|"`
      else
        __uv_output=`printf "%s" "${__uv_output}" \
          | sed -e "s|${__uv_user_defined_variable}|2031-12-31|"`
      fi
      continue
    elif [ "${__uv_var_name}" = "end_date_epoch" ]; then
      if [ -n "${__UAC_END_DATE_EPOCH:-}" ]; then
        __uv_output=`printf "%s" "${__uv_output}" \
          | sed -e "s|${__uv_user_defined_variable}|${__UAC_END_DATE_EPOCH:-}|"`
      else
        __uv_output=`printf "%s" "${__uv_output}" \
          | sed -e "s|${__uv_user_defined_variable}|1956527999|"`
      fi
      continue
    elif [ "${__uv_var_name}" = "user_home" ]; then
      __uv_output=`printf "%s" "${__uv_output}" \
        | sed -e "s|${__uv_user_defined_variable}|UAC_RUNTIME_VARIABLE_USER_HOME|"`
      continue
    elif [ "${__uv_var_name}" = "user" ]; then
      __uv_output=`printf "%s" "${__uv_output}" \
        | sed -e "s|${__uv_user_defined_variable}|UAC_RUNTIME_VARIABLE_USER|"`
      continue
    elif [ "${__uv_var_name}" = "line" ]; then
      __uv_output=`printf "%s" "${__uv_output}" \
        | sed -e "s|${__uv_user_defined_variable}|UAC_RUNTIME_VARIABLE_LINE|"`
      continue
    fi

    # map to real variable name
    __uv_var_name="__UAC_USER_DEFINED_VAR_${__uv_var_name}"

    # apply default only if variable is unset
    if eval "[ \"\${$__uv_var_name+x}\" = x ]"; then
      true
    else
      if [ -n "$__uv_var_default_value" ]; then 
        eval "${__uv_var_name}=\"\$__uv_var_default_value\""
      fi
    fi

    # get value (empty if still unset)
    eval "__uv_var_value=\"\${$__uv_var_name:-}\""

    # replace ONLY the first valid user-defined variable
    # shellcheck disable=SC2154
    __uv_output=`printf "%s" "${__uv_output}" \
      | sed -e "s|${__uv_user_defined_variable}|${__uv_var_value}|"`
    
  done

  printf "%s" "${__uv_output}" \
    | sed -e 's|#_PERCENTAGE_#|%|g' \
          -e 's|UAC_RUNTIME_VARIABLE_USER_HOME|%user_home%|g' \
          -e 's|UAC_RUNTIME_VARIABLE_USER|%user%|g' \
          -e 's|UAC_RUNTIME_VARIABLE_LINE|%line%|g'
}
