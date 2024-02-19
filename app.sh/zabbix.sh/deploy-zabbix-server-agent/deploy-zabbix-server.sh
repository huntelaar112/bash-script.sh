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

echo $dockerNetwork

[[ -z ${1} || ${1} = "-h" ]] && {
	help
	exit 1
}

[[ -z ${dockerNetwork} ]] && {
	dockerNetwork="bridge"
	log-info "Default: Use bridge network."
}

log-step "Deploy zabbix mariadb"
./deploy-mariadb.sh mariadb.env

log-step "Deploy zabbix server container."
runcmd=$(cat <<__
docker run -idt --name ${conname} --hostname ${conname} --restart always --network ${dockerNetwork} --ip ${zbserverip} \
-e DB_SERVER_HOST="${mysql_server}" -e MYSQL_USER="${mysql_user}" -e MYSQL_PASSWORD="${mysql_passwd}" \
-p 10051:10051 -e TZ=Asia/Ho_Chi_Minh --init "${image}"
__
)

echo "$runcmd"
eval "$runcmd"

log-step "Done."
done=yes
