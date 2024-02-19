#!/bin/bash

set +e
#set -u
done=no
exitval=0

namescrpit=${0:2}

function help() {
  echo "Usage: ${namescrpit} package
DESCRIPTION:
  Get information about last time package is updated.
NOTE: This script need sudo permission to execute."
  exit ${exitval}
}

numberArgs="1"
[[ ${1} = "-h" || -z ${1} || "$#" -lt ${numberArgs} ]] && {
  echo "Missing arguments."
  help
}

source $(which logshell)
## for log-info, log-error, log-warning, log-run, log-debug, log-step
packageName="$1"

log-step "Information about last time package is updated:"
zgrep -h "status installed ${packageName}" /var/log/dpkg.log* | sort | tail -n 1

log-step "More detail information (if it was installed by apt):"
#success command but can't use in script
# zcat -f $(ls -tr /var/log/apt/history.log*) | awk -v RS= '/${packageName}/{s=$0}; END{print s}'
#echo $cmd
test=$(zcat -f $(ls -tr /var/log/apt/history.log*) | grep $packageName | grep "Upgrade")
[[ ! -z $test ]] && {
  cmd="zcat -f $(ls -tr /var/log/apt/history.log*) | grep -A 1 -B 4 -P '^(?=.*${packageName})(?=.*Upgrade)'"
} || {
  cmd="zcat -f $(ls -tr /var/log/apt/history.log*) | grep -A 1 -B 3 -P '^(?=.*${packageName})(?=.*Install)'"
}

eval ${cmd}

done=yes
