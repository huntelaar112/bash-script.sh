#!/bin/bash

set -e
done=no
exitval=0

namescrpit=${0:2}
source $(which logshell)

function help() {
	echo "Usage: ${namescrpit} zbserver.env
  Note: This script need sudo permission to execute."
	exit ${exitval}
}

source ./zbserver.env

[[ -z ${1} || ${1} = "-h" ]] && {
	help
	exit 1
}

[[ -z ${dockerNetwork} ]] && {
	dockerNetwork="bridge"
	log-info "Default: Use bridge network."
}

runcmd=$(cat <<__
docker run -idt --name ${webconname} --hostname ${webconname} --network ${dockerNetwork} -e DB_SERVER_HOST="${mysql_server}" \
-e MYSQL_USER="${mysql_user}" -e MYSQL_PASSWORD="${mysql_passwd}" \
-e ZBX_SERVER_HOST=${zbserverip} -e PHP_TZ="Asia/Ho_Chi_Minh" -e TZ="Asia/Ho_Chi_Minh" "${webversion}"
__
)

echo "$runcmd"
eval "$runcmd"

log-step "Done."
done=yes
