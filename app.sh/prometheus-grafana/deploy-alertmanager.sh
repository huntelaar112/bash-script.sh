#!/bin/bash

set -e
done=no
exitval=0

namescrpit=${0:2}
source $(which logshell)

function help() {
  echo "Usage: ${namescrpit} [dockerNetwork] [image:tag]
  default image: \"bitnami/alertmanager:0.26.0\"
  Note: This script need sudo permission to execute."
  exit ${exitval}
}

conname="alertmanager"
dockerNetwork=$1
image=$2

[[ -z ${1} || ${1} = "-h" ]] && {
  help
}

[[ -z ${image} ]] && {
  log-info "Default: Use image \"bitnami/alertmanager:0.26.0\""
  image="bitnami/alertmanager:0.26.0"
}

[[ -z ${dockerNetwork} ]] && {
  dockerNetwork="bridge"
  log-info "Default: Use bridge network."
}

docker run -idt --name ${conname} --hostname ${conname} --restart always \
  --user root --network ${dockerNetwork} --ip "172.188.0.100" \
  -v $(pwd)/alertmanager.yml:/opt/bitnami/alertmanager/conf/alertmanager.yml \
  -e TZ=Asia/Ho_Chi_Minh "${image}" --cluster.advertise-address=172.188.0.100:9093 --config.file=/opt/bitnami/alertmanager/conf/alertmanager.yml

log-step "Done. alertmanager deployed."
done=yes