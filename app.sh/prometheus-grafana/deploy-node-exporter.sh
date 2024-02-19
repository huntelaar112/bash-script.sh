#!/bin/bash

set -e
done=no
exitval=0

namescrpit=${0:2}
source $(which logshell)

function help() {
  echo "Usage: ${namescrpit} [dockerNetwork] [image:tag]
  default image: \"bitnami/node-exporter:1.6.1\"
  Note: This script need sudo permission to execute."
  exit ${exitval}
}

conname="node-exporter"
dockerNetwork=$1
image=$2

[[ -z ${1} || ${1} = "-h" ]] && {
  help
}

[[ -z ${image} ]] && {
  log-info "Default: Use image \"bitnami/node-exporter:1.6.1\""
  image="bitnami/node-exporter:1.6.1"
}

[[ -z ${dockerNetwork} ]] && {
  dockerNetwork="bridge"
  log-info "Default: Use bridge network."
}

docker run -idt --name ${conname} --hostname ${conname} --restart always \
  --net="host" \
  --pid="host" \
  -v "/:/host:ro,rslave" \
  --user root -e TZ=Asia/Ho_Chi_Minh "${image}" --path.rootfs=/host

log-step "Done. node-exporter deployed."
done=yes