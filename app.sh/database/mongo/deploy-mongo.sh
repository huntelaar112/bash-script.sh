#!/bin/bash

set -e
done=no
exitval=0

namescrpit=${0:2}
source $(which logshell)

function help() {
	echo "Usage: ${namescrpit} mongo.env
  Note: This script need sudo permission to execute."
	exit ${exitval}
}
#echo $dockerNetwork
[[ -z ${1} || ${1} = "-h" ]] && {
	help
	exit 1
}

source ./mongo.env

[[ -z ${dockerNetwork} ]] && {
	dockerNetwork="bridge"
	log-info "Default: Use bridge network."
}

eport=""
[[ ! -z ${expose_port} ]] && {
	eport="-p ${expose_port}:27017"
}

runcmd=$(cat <<__
docker run  --network ${dockerNetwork} --name "${conname}" --hostname "${conname}" \
    --ip ${server} ${eport} --restart always -e TZ=Asia/Ho_Chi_Minh \
    --env MARIADB_USER="${user}" --env MARIADB_PASSWORD="${passwd}" \
    --env MARIADB_ROOT_PASSWORD="${passwd}" -v ${mountPoint}/configdb:/data/configdb \
	-v ${mountPoint}/db:/data/db -idt "${image}"
__
)

# GRANT ALL ON templates.* TO user@'%' IDENTIFIED BY 'password';

echo "$runcmd"
eval "$runcmd"

log-step "Done."
done=yes
