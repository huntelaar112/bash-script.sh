#!/bin/bash

set -e
#set +e # continue execute script in spite of command fail
#set -u
done=no
exitval=0

namescrpit=${0:2}

function help() {
  echo "Usage: ${namescrpit} <name> <network> <ip> [image]
  Note: This script need sudo permission to execute.
        Use default image sonarqube:10.2.1-community
  example:
        ./deploy-sonar.sh sonarqube ocrnetwork 172.172.0.100"
  exit ${exitval}
}

numberArgs="1"
[[ ${1} = "-h" || -z ${1} || "$#" -lt ${numberArgs} ]] && {
  echo "Missing arguments."
  help
}
source $(which logshell)
source $(which dsutils)

[[ $(docker-network-is-exist ocrnetwork) ]] || {
  docker-network-create ocrnetwork 172.172.0.0/16
} 

name=${1}
network=${2}
ip=${3}
image=${4}

[[ "${image}" == "" ]] && {
  image=sonarqube:10.2.1-community
}

[[ -z ${network} ]] && {
  network="bridge"
}

[[ -z ${ip} ]] && {
  ipconfig=""
} || {
  ipconfig="--ip ${ip}"
}

log-info "Deploy psql_sonar"
./deploy-psql.sh psql.env

docker rm sonarqube.old || :
docker rename sonarqube sonarqube.old || :

runcmd=$(cat <<__
docker run -d --name "${name}" --hostname "${name}" --network "${network}" ${ipconfig} \
  -p 7082:9000 \
  -e SONAR_JDBC_USERNAME=postgres \
  -e SONAR_JDBC_PASSWORD=password -e TZ=Asia/Ho_Chi_Minh \
  -v sonarqube_data:/mnt/containerdata/sonarqube/data \
  -v sonarqube_extensions:/mnt/containerdata/sonarqube/extensions \
  -v sonarqube_logs:/mnt/containerdata/sonarqube/logs \
  "${image}"
__)

#sonarqube:9.4.0-community if 10. config with docker or system.

echo "${runcmd}"
eval "${runcmd}"

done=yes
