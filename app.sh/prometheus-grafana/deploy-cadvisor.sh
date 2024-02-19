#!/bin/bash

set -e
done=no
exitval=0

namescrpit=${0:2}
source $(which logshell)

function help() {
  echo "Usage: ${namescrpit} [dockerNetwork] [image:tag]
  default image: \"gcr.io/cadvisor/cadvisor-amd64:v0.47.2\"
  Note: This script need sudo permission to execute."
  exit ${exitval}
}

conname="cadvisor"
dockerNetwork=$1
image=$2

[[ -z ${1} || ${1} = "-h" ]] && {
  help
}

[[ -z ${image} ]] && {
  log-info "Default: Use image \"gcr.io/cadvisor/cadvisor-amd64:v0.47.2\""
  image="gcr.io/cadvisor/cadvisor-amd64:v0.47.2"
}

[[ -z ${dockerNetwork} ]] && {
  dockerNetwork="bridge"
  log-info "Default: Use bridge network."
}

#google/cadvisor:v0.28.0 old image for centos 7.

docker run -idt --name ${conname} --hostname ${conname} --restart always \
  --network "${dockerNetwork}" --ip "172.188.0.3" \
  -v /:/rootfs:ro \
  -v /var/run:/var/run:ro \
  -v /sys:/sys:ro \
  -v /var/lib/docker/:/var/lib/docker:ro \
  -v /dev/disk/:/dev/disk:ro \
  --privileged --device=/dev/kmsg \
  -e TZ=Asia/Ho_Chi_Minh "${image}"

log-step "Done. cadvisor deployed."

done=yes
