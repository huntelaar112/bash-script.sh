#!/bin/bash

set -e
done=no
exitval=0

namescrpit=${0:2}
source $(which logshell)

function help() {
	echo "Usage: ${namescrpit} mariadb.env
  Note: This script need sudo permission to execute."
	exit ${exitval}
}
#echo $dockerNetwork
[[ -z ${1} || ${1} = "-h" ]] && {
	help
	exit 1
}

source ./mariadb.env

[[ -z ${dockerNetwork} ]] && {
	dockerNetwork="bridge"
	log-info "Default: Use bridge network."
}

runcmd=$(cat <<__
docker run  --network ${dockerNetwork} --name "${conname}" --hostname "${conname}" \
    --ip ${mysql_server} -p 3306:3306 --restart always -e TZ=Asia/Ho_Chi_Minh \
    --env MARIADB_USER="${mysql_user}" --env MARIADB_PASSWORD="${mysql_passwd}" \
    --env MARIADB_ROOT_PASSWORD="${mysql_passwd}" -idt "${image}"
__
)

# GRANT ALL ON templates.* TO user@'%' IDENTIFIED BY 'password';

echo "$runcmd"
eval "$runcmd"

log-step "Done."
done=yes
