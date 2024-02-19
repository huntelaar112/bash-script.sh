#!/bin/bash

set -e
done=no
exitval=0

namescrpit=${0:2}

function help() {
	echo "Usage: ${namescrpit} psql.env
  Note: This script need sudo permission to execute."
	exit ${exitval}
}
#echo $dockerNetwork
[[ -z ${1} || ${1} = "-h" ]] && {
	help
}

source "${1}"

[[ -z ${dockerNetwork} ]] && {
	dockerNetwork="bridge"
	echo "Default: Use bridge network."
}

runcmd=$(cat <<__
docker run  --network ${dockerNetwork} --name "${conname}" --hostname "${conname}" \
    --ip ${psql_server} -p 5432:5432 --restart always -e TZ=Asia/Ho_Chi_Minh \
    --env POSTGRES_PASSWORD="${psql_passwd}" \
	-e PGDATA=/var/lib/postgresql/data/pgdata \
	-v "${mount_point}":/var/lib/postgresql/data -idt "${image}"
__
)

# GRANT ALL ON templates.* TO user@'%' IDENTIFIED BY 'password';

echo "$runcmd"
eval "$runcmd"

echo "Done."
done=yes
