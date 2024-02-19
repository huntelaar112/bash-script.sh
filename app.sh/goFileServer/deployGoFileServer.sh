#!/bin/bash

set -e
#set +e # continue execute script in spite of command fail
#set -u
done=no
exitval=0

namescrpit=${0:2}

function help() {
  echo "Usage: ${namescrpit} <publicDir> [httpAuth]
  Note: This script need sudo permission to execute."
  exit ${exitval}
}

numberArgs="1"
[[ ${1} = "-h" || -z ${1} || "$#" -lt ${numberArgs} ]] && {
  echo "Missing arguments."
  help
}

httpAuth="${2}"
publicDir="${1}"

[[ -z ${httpAuth} ]] && {
    enableAuth=""
} || {
    enableAuth="--auth-type http --auth-http ${httpAuth}"
}


source $(which logshell)
source $(which dsutils)

[[ $(docker-network-is-exist ocrnetwork) ]] || {
  docker-network-create ocrnetwork 172.172.0.0/16
} 

currentFileSv="logserver"

docker rm -f "${currentFileSv}.old" || :
docker stop ${currentFileSv} &>/dev/null || :
docker rename ${currentFileSv} "${currentFileSv}.old" &>/dev/null|| :

runcmd=$(cat <<__
docker run -idt -v ${publicDir}:/app/public --name logserver --hostname logserver --network ocrnetwork \
        -p 7001:7001 --restart always \
        --user 1001 -e TZ=Asia/Ho_Chi_Minh mannk98/gohttpserver \
        ${enableAuth} --prefix /logs
__)

echo "${runcmd}"
eval "${runcmd}"

done=yes