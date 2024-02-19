#!/bin/bash

set -e
done=no
exitval=0

namescrpit=${0:2}
source $(which logshell)

function help() {
  echo "Usage: ${namescrpit} [dockerNetwork] [image:tag]
  default image: \"bitnami/prometheus:2.47.2\"
  Note: This script need sudo permission to execute."
  exit ${exitval}
}

conname="prometheus"
dockerNetwork=$1
image=$2
dataDir="/mnt/containerdata/prometheus/data"

[[ -z ${1} || ${1} = "-h" ]] && {
  help
}

[[ -z ${image} ]] && {
  log-info "Default: Use image \"bitnami/prometheus:2.47.2\""
  image="bitnami/prometheus:2.47.2"
}

[[ -z ${dockerNetwork} ]] && {
  dockerNetwork="bridge"
  log-info "Default: Use bridge network."
}

cmd_options="--web.config.file=/opt/bitnami/prometheus/conf/web.yml
--config.file=/opt/bitnami/prometheus/conf/prometheus.yml
--storage.tsdb.path=/opt/bitnami/prometheus/data
--web.console.libraries=/opt/bitnami/prometheus/conf/console_libraries
--web.console.templates=/opt/bitnami/prometheus/conf/consoles "

# wrk dir /opt/bitnami/prometheus
docker run --name ${conname} --hostname ${conname} --restart always \
  --network "${dockerNetwork}" --ip 172.188.0.2 -p 9090:9090 \
  --user root -e TZ=Asia/Ho_Chi_Minh \
  -v $(pwd)/prometheus.yml:/opt/bitnami/prometheus/conf/prometheus.yml \
  -v $(pwd)/web.yml:/opt/bitnami/prometheus/conf/web.yml \
  -v ${dataDir}:/opt/bitnami/prometheus/data -idt "${image}" ${cmd_options}

log-step "Done. prometheus deployed,  data saved in: ${dataDir}"
done=yes

#https://grafana.com/grafana/dashboards/193-docker-monitoring/
#https://grafana.com/grafana/dashboards/1860-node-exporter-full/